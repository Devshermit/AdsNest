import 'package:intl/intl.dart';

class AppFormatters {
  // แปลงยอดเงิน เช่น 145200.0 -> ฿145,200.00
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    return formatter.format(amount);
  }

  // แปลงตัวเลขย่อ เช่น 1200 -> 1.2K, 1500000 -> 1.5M
  static String formatCompactNumber(num number) {
    final formatter = NumberFormat.compact(locale: 'th_TH');
    return formatter.format(number);
  }

  // แปลง ROAS เช่น 3.6 -> 3.60x
  static String formatRoas(double roas) {
    return '${roas.toStringAsFixed(2)}x';
  }

  // แปลงเปอร์เซ็นต์ เช่น 12.5 -> +12.5% หรือ -5.0%
  static String formatPercentage(double percent) {
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(1)}%';
  }

  // แปลงวันที่ เช่น 2026-08-29 -> 29 ส.ค. 2026
  static String formatThaiDate(DateTime date) {
    final formatter = DateFormat('d MMM yyyy', 'th');
    return formatter.format(date);
  }

  // แปลงเวลาสำหรับแชท เช่น 14:30 น.
  static String formatChatTime(DateTime date) {
    final formatter = DateFormat('HH:mm น.');
    return formatter.format(date);
  }
}
