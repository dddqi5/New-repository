import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../services/api_services.dart';
import '../widgets/common.dart';
import 'about_page.dart';

/// 设置页：API Key、主题、缓存。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _deepseek = TextEditingController();
  final _searchKey = TextEditingController();
  final _recipeKey = TextEditingController();
  String _searchProvider = 'brave';
  String _recipeProvider = 'spoonacular';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _apply(ref.read(apiConfigProvider));
  }

  void _apply(ApiConfig cfg) {
    _deepseek.text = cfg.deepseekKey;
    _searchKey.text = cfg.searchKey;
    _recipeKey.text = cfg.recipeKey;
    _searchProvider = cfg.searchProvider;
    _recipeProvider = cfg.recipeProvider;
  }

  @override
  void dispose() {
    _deepseek.dispose();
    _searchKey.dispose();
    _recipeKey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    await ref.read(apiConfigProvider.notifier).save(ApiConfig(
          deepseekKey: _deepseek.text.trim(),
          searchProvider: _searchProvider,
          searchKey: _searchKey.text.trim(),
          recipeProvider: _recipeProvider,
          recipeKey: _recipeKey.text.trim(),
        ));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已保存 API 配置')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiConfig>(apiConfigProvider, (_, next) => _apply(next));
    final mode = ref.watch(themeModeProvider);
    final cfg = ref.watch(apiConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusCard(cfg),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('API 密钥',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('密钥仅保存在本机数据库，不会上传。',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: _deepseek,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'DeepSeek API Key',
                    hintText: 'sk-...',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _searchProvider,
                  decoration: const InputDecoration(labelText: '搜索服务'),
                  items: const [
                    DropdownMenuItem(value: 'brave', child: Text('Brave Search')),
                    DropdownMenuItem(value: 'tavily', child: Text('Tavily')),
                  ],
                  onChanged: (v) =>
                      setState(() => _searchProvider = v ?? _searchProvider),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchKey,
                  decoration: const InputDecoration(
                    labelText: '搜索 API Key',
                    hintText: 'Brave / Tavily 密钥',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _recipeProvider,
                  decoration: const InputDecoration(labelText: '食谱服务（可选）'),
                  items: const [
                    DropdownMenuItem(
                        value: 'spoonacular', child: Text('Spoonacular')),
                    DropdownMenuItem(value: 'edamam', child: Text('Edamam')),
                  ],
                  onChanged: (v) =>
                      setState(() => _recipeProvider = v ?? _recipeProvider),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _recipeKey,
                  decoration: const InputDecoration(
                    labelText: '食谱 API Key（可选）',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  onPressed: _save,
                  child: const Text('保存 API 配置'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('外观',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('跟随系统')),
                    ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      ref.read(themeModeProvider.notifier).setMode(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('清除今日食谱缓存并重新生成'),
                  onTap: () async {
                    await ref.read(mealPlanRepositoryProvider).deleteAllPlans();
                    ref.invalidate(mealPlanProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('缓存已清除，回首页将重新生成')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于与免责声明'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(ApiConfig cfg) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(
        children: [
          Icon(
            cfg.canGoOnline ? Icons.cloud_done : Icons.cloud_off,
            color: cfg.canGoOnline ? scheme.primary : scheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cfg.canGoOnline ? '联网模式已就绪' : '当前为示例数据模式',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  cfg.canGoOnline
                      ? '将联网检索权威来源并生成食谱'
                      : '填写下方 API Key 后自动切换为联网检索',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
