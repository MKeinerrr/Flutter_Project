class ScreenFormatters {
  const ScreenFormatters._();

  static String formatCurrency(num value) {
    final bool isNegative = value < 0;
    final num absValue = value.abs();
    int integerPart = absValue.floor();
    int decimalPart = ((absValue - integerPart) * 100).round();

    if (decimalPart >= 100) {
      integerPart += 1;
      decimalPart = 0;
    }

    final String text = integerPart.toString();
    final StringBuffer out = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      out.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        out.write('.');
      }
    }

    final String formatted = out.toString().split('').reversed.join();
    final String withDecimals = decimalPart == 0
        ? formatted
        : '$formatted,${decimalPart.toString().padLeft(2, '0')}';
    return isNegative ? '-$withDecimals' : withDecimals;
  }
}
