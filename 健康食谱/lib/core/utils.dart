/// 日期与数字工具。
/// 注意：这里**不使用 intl 的语言包**，全部手动格式化，
/// 避免未初始化中文语言数据时 DateFormat 抛异常导致页面崩溃。
class AppDate {
  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  static String toKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String todayKey() => toKey(DateTime.now());

  static String display(DateTime d) {
    final w = _weekdays[d.weekday - 1];
    return '${d.year}年${d.month}月${d.day}日 星期$w';
  }

  static String displayKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    return display(parsed);
  }

  static DateTime parseKey(String key) =>
      DateTime.tryParse(key) ?? DateTime.now();

  static bool isSameDay(String key, DateTime d) => key == toKey(d);
}

class NumFormat {
  static String cal(double v) => '${v.round()} kcal';

  static String grams(double v) => '${v.round()} g';

  static String percent(double v) => '${(v * 100).round()}%';

  static String one(double v) => v.toStringAsFixed(1);
}
