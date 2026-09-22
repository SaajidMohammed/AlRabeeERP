import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##,###');

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDate = DateFormat('dd/MM/yy');

  static String currency(num amount) => _currencyFormat.format(amount);
  static String compactCurrency(num amount) => _compactCurrency.format(amount);
  static String number(num value) => _numberFormat.format(value);
  static String date(DateTime dt) => _dateFormat.format(dt);
  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String shortDate(DateTime dt) => _shortDate.format(dt);

  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateFormat.format(dt);
  }
}
