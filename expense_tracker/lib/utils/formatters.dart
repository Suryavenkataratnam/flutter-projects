import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final format = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 2);
  return format.format(amount);
}

String formatDateShort(String iso) {
  final d = DateTime.parse(iso);
  return DateFormat.yMMMd().format(d);
}
