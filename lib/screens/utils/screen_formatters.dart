class ScreenFormatters {
  const ScreenFormatters._();

  static String formatCurrency(int value) {
    final String text = value.toString();
    final StringBuffer out = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      out.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        out.write('.');
      }
    }

    return out.toString().split('').reversed.join();
  }
}
