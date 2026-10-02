import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../ui/widgets/profile_form.dart';
import 'main_shell.dart';

/// 首次启动引导页：档案为空时展示，可「以后再说」跳过。
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('完善个人档案')),
      body: ProfileForm(
        submitLabel: '保存并开始',
        onSubmit: (p) => ref.read(profileProvider.notifier).save(p),
        skipLabel: '以后再说（稍后在「我的」里填写）',
        onSkip: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        },
      ),
    );
  }
}
