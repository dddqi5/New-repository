import '../core/constants.dart';
import '../core/utils.dart';
import '../data/models.dart';
import 'api_services.dart';

/// 联网获取食材详情：搜索权威来源 → DeepSeek 结构化为固定 JSON → 解析。
/// 失败返回 null，由上层回退到示例数据或占位数据。
class IngredientService {
  IngredientService({required this.search, required this.llm});

  final SearchService search;
  final DeepSeekService llm;

  Future<Ingredient?> fetch(String name, ApiConfig cfg) async {
    if (!cfg.hasLlm) return null;

    final hits = await search.search(
      '$name 营养成分 每100克 功效 搭配 禁忌 药物相互作用 权威来源',
      cfg,
    );
    final context = hits.isEmpty
        ? '（未取到搜索结果，请仅依据权威来源知识作答并标注来源）'
        : hits.take(6).map((h) => '- ${h.title} | ${h.publisher} | ${h.url}').join('\n');

    final today = AppDate.todayKey();
    final system = '''
你是严谨的营养学助手。只输出一个 JSON 对象，不要解释、不要 Markdown 代码块。
规则：
1. 所有营养数据与结论必须来自权威来源（WHO、中国居民膳食指南、NIH、USDA、Harvard、Mayo Clinic、CDC、NHS）。
2. "注意搭配"分两类：cautions_evidence（有科学证据）与 cautions_folk（证据不足/民间说法）。
3. possible_effects 只写有来源的可能影响，禁止"有毒/中毒/相克"等无来源结论。
4. drug_interactions 必须基于可靠来源，如葡萄柚与他汀；没有证据就留空数组。
5. evidence_level 取值：strong/medium/weak/folk/insufficient。
JSON 结构：
{"name":"","name_en":"","evidence_level":"medium",
 "benefits":["3-5条"],
 "nutrition_per_100g":{"calories":0,"protein":0,"carbs":0,"fat":0,"fiber":0,"sodium":0,"calcium":0,"iron":0,"vitamins":{"维生素C_mg":0}},
 "pairings":["推荐搭配"],
 "cautions_evidence":["有证据的注意搭配"],
 "cautions_folk":["证据不足/民间说法"],
 "possible_effects":["有来源的可能影响"],
 "drug_interactions":["药物交互"],
 "sources":[{"title":"","url":"https://...","publisher":"USDA","evidence_level":"strong","retrieved_date":"$today"}]}
''';

    final user = '''
食材：$name
今天是 $today。
可用搜索来源：
$context
请输出该食材对应的 JSON。
''';

    final data = await llm.jsonChat(system: system, user: user, cfg: cfg);
    if (data == null) return null;

    return _parse(data, name);
  }

  Ingredient _parse(Map<String, dynamic> data, String fallbackName) {
    final nutrition = data['nutrition_per_100g'];
    IngredientNutrient? nutrient;
    if (nutrition is Map) {
      final nm = Map<String, dynamic>.from(nutrition);
      final vitamins = nm['vitamins'];
      nutrient = IngredientNutrient(
        caloriesKcal: _num(nm['calories']),
        proteinG: _num(nm['protein']),
        carbsG: _num(nm['carbs']),
        fatG: _num(nm['fat']),
        fiberG: _num(nm['fiber']),
        sodiumMg: _num(nm['sodium']),
        calciumMg: _num(nm['calcium']),
        ironMg: _num(nm['iron']),
        vitamins: vitamins is Map ? Map<String, dynamic>.from(vitamins) : const {},
      );
    }

    final sourcesJson = data['sources'];
    final sources = <IngredientSource>[];
    if (sourcesJson is List) {
      for (final s in sourcesJson) {
        if (s is! Map) continue;
        final sm = Map<String, dynamic>.from(s);
        final url = (sm['url'] ?? '').toString();
        if (url.isEmpty) continue;
        sources.add(IngredientSource(
          title: (sm['title'] ?? '').toString(),
          url: url,
          publisher: sm['publisher']?.toString(),
          retrievedDate: (sm['retrieved_date'] ?? AppDate.todayKey()).toString(),
          evidenceLevel:
              (sm['evidence_level'] ?? EvidenceLevel.medium).toString(),
        ));
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return Ingredient(
      name: (data['name'] ?? fallbackName).toString(),
      nameEn: data['name_en']?.toString(),
      evidenceLevel:
          (data['evidence_level'] ?? EvidenceLevel.insufficient).toString(),
      benefits: _strList(data['benefits']),
      pairings: _strList(data['pairings']),
      cautionsEvidence: _strList(data['cautions_evidence']),
      cautionsFolk: _strList(data['cautions_folk']),
      possibleEffects: _strList(data['possible_effects']),
      drugInteractions: _strList(data['drug_interactions']),
      disclaimer: AppDefaults.disclaimer,
      fetchedAt: now,
      expireAt: now + const Duration(days: 30).inMilliseconds,
      nutrient: nutrient,
      sources: sources,
    );
  }

  List<String> _strList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }

  double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
