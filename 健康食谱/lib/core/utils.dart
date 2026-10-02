import 'package:intl/intl.dart';

/// 日期与数字工具
class AppDate {
  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _display = DateFormat('yyyy年M月d日 EEEE', 'zh');

  static String toKey(DateTime d) => _day.format(DateTime(d.year, d.month, d.day));

  static String todayKey() => toKey(DateTime.now());

  static String display(DateTime d) => _display.format(d);

  static String displayKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    return _display.format(parsed);
  }

  static DateTime parseKey(String key) => DateTime.tryParse(key) ?? DateTime.now();

  static bool isSameDay(String key, DateTime d) => key == toKey(d);
}

class NumFormat {
  static String cal(double v) => '${v.round()} kcal';

  static String grams(double v) => '${v.round()} g';

  static String percent(double v) => '${(v * 100).round()}%';

  static String one(double v) => v.toStringAsFixed(1);
}
