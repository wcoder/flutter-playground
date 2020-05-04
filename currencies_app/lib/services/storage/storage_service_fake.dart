import 'package:moolax/business_logic/models/currency.dart';
import 'package:moolax/business_logic/models/rate.dart';

import 'storage_service.dart';


// This is not used in the final app, but I am leaving it in to show how you
// could use fake data during development. This lets you work on your core business
// logic without worrying about the details of how you will store the data locally.
// Maybe you will used shared preferences or maybe a SQL database. That's a
// detail that you can worry about later.
class FakeStorageService implements StorageService {

  @override
  Future<List<Rate>> getExchangeRateData() async {
    List<Rate> list = [];
    list.add(Rate(
      baseCurrency: 'USD',
      quoteCurrency: 'EUR',
      exchangeRate: 0.91,
    ));
    list.add(Rate(
      baseCurrency: 'USD',
      quoteCurrency: 'CNY',
      exchangeRate: 7.05,
    ));
    list.add(Rate(
      baseCurrency: 'USD',
      quoteCurrency: 'MNT',
      exchangeRate: 2668.37,
    ));
    return list;
  }

  @override
  Future cacheExchangeRateData(List<Rate> data) {
    return null;
  }

  @override
  Future<List<Currency>> getFavoriteCurrencies() async {
    List<Currency> list = [];
    list.add(Currency('USD', amount: 0.0));
    list.add(Currency('EUR', amount: 0.0));
    list.add(Currency('CNY', amount: 0.0));
    list.add(Currency('MNT', amount: 0.0));
    return list;
  }

  @override
  Future saveFavoriteCurrencies(List<Currency> data) {
    return null;
  }

  @override
  Future<bool> isExpiredCache() async {
    return false;
  }

}
