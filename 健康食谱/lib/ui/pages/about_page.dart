import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// 关于与免责声明页。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('关于与免责声明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('健康食谱', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('个人使用的健康食谱助手：本地公式计算营养目标，联网检索、标注来源生成每日食谱。'),
          const SizedBox(height: 20),
          Text('数据来源优先', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('WHO、中国居民膳食指南、NIH、USDA、Harvard、Mayo Clinic、CDC、NHS。'),
          const SizedBox(height: 20),
          Text('计算说明', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'BMI、BMR、TDEE 与每日目标热量均由本地公式计算（Mifflin-St Jeor），不由 AI 推测。\n'
            '三餐热量分配：早餐 30%、午餐 40%、晚餐 30%。',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_outlined, color: scheme.error),
                const SizedBox(width: 12),
                const Expanded(child: Text(AppDefaults.disclaimer)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('开源许可', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('本项目使用以下开源库：Flutter、Riverpod、Dio、sqflite、fl_chart、'
              'cached_network_image、shimmer、url_launcher、intl、path。'
              '各库遵循其原始许可证（MIT / BSD / Apache 2.0）。'),
        ],
      ),
    );
  }
}
