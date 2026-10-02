import 'dart:convert';

import 'package:dio/dio.dart';

/// 运行时 API 配置（从 app_setting 表读取）。
class ApiConfig {
  final String deepseekKey;
  final String searchProvider; // brave / tavily
  final String searchKey;
  final String recipeProvider; // spoonacular / edamam
  final String recipeKey;

  const ApiConfig({
    this.deepseekKey = '',
    this.searchProvider = 'brave',
    this.searchKey = '',
    this.recipeProvider = 'spoonacular',
    this.recipeKey = '',
  });

  bool get hasLlm => deepseekKey.trim().isNotEmpty;
  bool get hasSearch => searchKey.trim().isNotEmpty;
  bool get hasRecipe => recipeKey.trim().isNotEmpty;

  /// 只要 LLM 或搜索任一可用，就能尝试联网生成。
  bool get canGoOnline => hasLlm || hasSearch;
}

class SearchHit {
  final String title;
  final String url;
  final String snippet;
  final String publisher;

  const SearchHit({
    required this.title,
    required this.url,
    this.snippet = '',
    this.publisher = '',
  });
}

/// 搜索服务：Brave 或 Tavily。
class SearchService {
  SearchService(this._dio);
  final Dio _dio;

  Future<List<SearchHit>> search(String query, ApiConfig cfg) async {
    if (!cfg.hasSearch) return [];
    try {
      if (cfg.searchProvider == 'tavily') {
        return await _tavily(query, cfg.searchKey);
      }
      return await _brave(query, cfg.searchKey);
    } catch (_) {
      return [];
    }
  }

  Future<List<SearchHit>> _brave(String query, String key) async {
    final resp = await _dio.get(
      'https://api.search.brave.com/res/v1/web/search',
      queryParameters: {'q': query, 'count': 8, 'country': 'cn'},
      options: Options(headers: {
        'Accept': 'application/json',
        'X-Subscription-Token': key,
      }),
    );
    final data = resp.data;
    final results = (data is Map ? data['web'] : null);
    final list = (results is Map ? results['results'] : null);
    if (list is! List) return [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return SearchHit(
        title: (m['title'] ?? '').toString(),
        url: (m['url'] ?? '').toString(),
        snippet: (m['description'] ?? '').toString(),
        publisher: (m['profile'] is Map)
            ? ((m['profile'] as Map)['name'] ?? '').toString()
            : '',
      );
    }).toList();
  }

  Future<List<SearchHit>> _tavily(String query, String key) async {
    final resp = await _dio.post(
      'https://api.tavily.com/search',
      data: {
        'api_key': key,
        'query': query,
        'max_results': 8,
        'search_depth': 'basic',
      },
    );
    final data = resp.data;
    final list = (data is Map ? data['results'] : null);
    if (list is! List) return [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return SearchHit(
        title: (m['title'] ?? '').toString(),
        url: (m['url'] ?? '').toString(),
        snippet: (m['content'] ?? '').toString(),
        publisher: Uri.tryParse((m['url'] ?? '').toString())?.host ?? '',
      );
    }).toList();
  }
}

/// DeepSeek 对话服务（OpenAI 兼容接口）。
class DeepSeekService {
  DeepSeekService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>?> jsonChat({
    required String system,
    required String user,
    required ApiConfig cfg,
    double temperature = 0.3,
  }) async {
    if (!cfg.hasLlm) return null;
    try {
      final resp = await _dio.post(
        'https://api.deepseek.com/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer ${cfg.deepseekKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': 'deepseek-chat',
          'temperature': temperature,
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': user},
          ],
        },
      );
      final content = resp.data['choices'][0]['message']['content'].toString();
      return _extractJson(content);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _extractJson(String text) {
    var t = text.trim();
    if (t.startsWith('```')) {
      t = t.replaceAll('```json', '').replaceAll('```', '').trim();
    }
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(t.substring(start, end + 1));
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }
}

/// 食谱数据服务（Spoonacular）。可选，用于补充菜品图与营养。
class RecipeService {
  RecipeService(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> searchRecipes(
      String query, ApiConfig cfg) async {
    if (!cfg.hasRecipe || cfg.recipeProvider != 'spoonacular') return [];
    try {
      final resp = await _dio.get(
        'https://api.spoonacular.com/recipes/complexSearch',
        queryParameters: {
          'apiKey': cfg.recipeKey,
          'query': query,
          'number': 5,
          'addRecipeNutrition': true,
          'language': 'zh',
        },
      );
      final results = resp.data['results'];
      if (results is! List) return [];
      return results.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
