import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) digits = '0';
    final value = int.parse(digits);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final newText = formatter.format(value / 100.0);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
