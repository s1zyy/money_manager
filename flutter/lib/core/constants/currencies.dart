const List<({String code, String symbol, String name})> supportedCurrencies = [
  (code: 'EUR', symbol: '€', name: 'Euro'),
  (code: 'USD', symbol: '\$', name: 'US Dollar'),
  (code: 'GBP', symbol: '£', name: 'British Pound'),
  (code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  (code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  (code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
  (code: 'KRW', symbol: '₩', name: 'South Korean Won'),
  (code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  (code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
  (code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  (code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  (code: 'CHF', symbol: '₣', name: 'Swiss Franc'),
  (code: 'THB', symbol: '฿', name: 'Thai Baht'),
  (code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  (code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
  (code: 'KZT', symbol: '₸', name: 'Kazakhstani Tenge'),
  (code: 'GEL', symbol: '₾', name: 'Georgian Lari'),
  (code: 'UAH', symbol: '₴', name: 'Ukrainian Hryvnia'),
  (code: 'ILS', symbol: '₪', name: 'Israeli Shekel'),
  (code: 'RUB', symbol: '₽', name: 'Российский рубль'),
];


String currencySymbol (String code) {
  return supportedCurrencies
    .firstWhere((c) => c.code == code, orElse: () => (code: code, symbol: code, name: ''))
    .symbol;
}