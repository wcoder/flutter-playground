import 'package:moolax/business_logic/models/currency.dart';
import 'package:moolax/business_logic/models/rate.dart';

// This is the contract that all currency services must follow. Using an abstract
// class like this allows you to swap concrete implementations. This is useful
// for separating architectural layers. It also makes testing and development
// easier because you can provide a mock implementation or fake data.
abstract class CurrencyService {
  Future<List<Rate>> getAllExchangeRates({String base});

  Future<List<Currency>> getFavoriteCurrencies();

  Future<void> saveFavoriteCurrencies(List<Currency> data);
}

