import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'main_shell.dart';
import 'onboarding_page.dart';

/// 启动门：根据档案是否完整，决定去引导页还是主框架。
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => const _SplashScaffold(),
      error: (e, _) => _SplashScaffold(error: '$e'),
      data: (p) {
        if (p == null || !p.isComplete) return const OnboardingPage();
        return const MainShell();
      },
    );
  }
}

class _SplashScaffold extends StatelessWidget {
  const _SplashScaffold({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text('健康食谱',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            if (error == null)
              const CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('初始化失败：$error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}
