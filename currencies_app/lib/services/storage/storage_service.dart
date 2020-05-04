import 'package:moolax/business_logic/models/currency.dart';
import 'package:moolax/business_logic/models/rate.dart';

// This is the contract that all storage services must follow. Using an abstract
// class like this allows you to swap concrete implementations. This is useful
// for separating architectural layers. It also makes testing and development
// easier because you can provide a mock implementation or fake data.
abstract class StorageService {
  Future cacheExchangeRateData(List<Rate> data);

  Future<List<Rate>> getExchangeRateData();

  Future<List<Currency>> getFavoriteCurrencies();

  Future saveFavoriteCurrencies(List<Currency> data);

  Future<bool> isExpiredCache();
}