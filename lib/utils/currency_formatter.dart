class CurrencyFormatter {
  static String formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  static String formatPriceWithoutSymbol(double price) {
    return price.toStringAsFixed(2);
  }

  static String get currencySymbol => 'Rs.';
}
