import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/profile_form.dart';
import 'settings_page.dart';

/// 我的 · 个人档案（唯一数据源）
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ref.watch(profileProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              title: '加载失败',
              subtitle: '$e',
            ),
            data: (profile) => ProfileForm(
              initial: profile,
              submitLabel: '保存并重新生成食谱',
              onSubmit: (p) async {
                await ref.read(profileProvider.notifier).save(p);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已保存，今日食谱将重新生成')),
                  );
                }
              },
            ),
          ),
    );
  }
}
