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

String formatDate(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}

String monthToString(int month) {
  final formatter = DateFormat('MMMM', 'pt_BR');

  final monthName = formatter.format(DateTime(0, month));
  return monthName[0].toUpperCase() + monthName.substring(1);
}
