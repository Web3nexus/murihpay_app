class AppCurrencies {
  static const List<String> supported = [
    'USD', 'NGN', 'GBP', 'EUR', 'CAD', 'KES', 'GHS', 'USDC', 'USDT',
  ];

  static const List<String> fiat = [
    'USD', 'NGN', 'GBP', 'EUR', 'CAD', 'KES', 'GHS',
  ];

  static const List<String> cryptoStable = ['USDC', 'USDT'];

  static const Map<String, String> symbols = {
    'USD': r'$', 'NGN': '₦', 'GBP': '£', 'EUR': '€',
    'CAD': r'C$', 'KES': 'KSh', 'GHS': 'GH₵',
    'USDC': r'$', 'USDT': '₮',
  };

  static const Map<String, String> flags = {
    'USD': '\u{1F1FA}\u{1F1F8}', 'NGN': '\u{1F1F3}\u{1F1EC}',
    'GBP': '\u{1F1EC}\u{1F1E7}', 'EUR': '\u{1F1EA}\u{1F1FA}',
    'CAD': '\u{1F1E8}\u{1F1E6}', 'KES': '\u{1F1F0}\u{1F1EA}',
    'GHS': '\u{1F1EC}\u{1F1ED}', 'USDC': '\u{1F535}', 'USDT': '\u{1F7E2}',
  };

  static const Map<String, String> names = {
    'USD': 'US Dollar', 'NGN': 'Nigerian Naira', 'GBP': 'British Pound',
    'EUR': 'Euro', 'CAD': 'Canadian Dollar', 'KES': 'Kenyan Shilling',
    'GHS': 'Ghanaian Cedi', 'USDC': 'USD Coin', 'USDT': 'Tether USD',
  };

  static String symbol(String code) => symbols[code] ?? code;
  static String flag(String code) => flags[code] ?? '\u{1F310}';
  static String name(String code) => names[code] ?? code;
  static bool isSupported(String code) => supported.contains(code);
}
