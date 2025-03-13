const envCurrency = String.fromEnvironment('CURRENCY');

abstract final class K {
  static const String currency = envCurrency == '' ? 'gbp' : envCurrency;
}
