class FormatPrice {
  static String formatPrice(double price) {
    String priceStr = price.toStringAsFixed(0);
    String result = '';
    int count = 0;

    for (int i = priceStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = priceStr[i] + result;
      count++;
    }

    return '$resultđ';
  }
}
