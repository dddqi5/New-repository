import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/ingredient_sheet.dart';

/// 搜索页：搜索食材/菜品，点击进入食材详情。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  List<SearchHistoryItem> _history = const [];

  static const _suggestions = ['鸡蛋', '燕麦', '鸡胸肉', '西兰花', '三文鱼', '番茄', '牛奶', '豆腐'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await ref.read(recordRepositoryProvider).searchHistory();
    if (mounted) setState(() => _history = items);
  }

  Future<void> _submit(String value) async {
    final q = value.trim();
    if (q.isEmpty) return;
    _controller.text = q;
    await ref.read(recordRepositoryProvider).addSearchHistory(q, 'ingredient');
    await _loadHistory();
    setState(() => _query = q);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '输入食材或菜品，如：三文鱼',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onSubmitted: _submit,
            ),
          ),
          Expanded(
            child: _query.isEmpty ? _emptyBody() : _resultBody(),
          ),
        ],
      ),
    );
  }

  Widget _emptyBody() {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_history.isNotEmpty) ...[
          Row(
            children: [
              Text('最近搜索',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await ref.read(recordRepositoryProvider).clearSearchHistory();
                  await _loadHistory();
                },
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history
                .map((h) => ActionChip(
                      label: Text(h.query),
                      onPressed: () => _submit(h.query),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        Text('推荐食材', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((s) => ActionChip(
                    avatar: const Icon(Icons.search, size: 16),
                    label: Text(s),
                    onPressed: () => _submit(s),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: scheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '所有营养结论均联网检索并标注来源与检索日期；未配置 API Key 时显示内置示例数据。',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        AppCard(
          onTap: () => showIngredientSheet(context, ref, _query),
          child: Row(
            children: [
              const Icon(Icons.restaurant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('查看「$_query」营养详情',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text('营养优势 · 关键营养素 · 搭配与禁忌 · 证据等级 · 来源',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }
}
