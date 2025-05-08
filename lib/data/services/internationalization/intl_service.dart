import 'package:intl/intl.dart';

String formatCurrency(int valueInCents) {
  final double valueInReais = valueInCents / 100;

  final formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  return formatter.format(valueInReais);
}
