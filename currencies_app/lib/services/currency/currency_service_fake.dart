import 'package:moolax/business_logic/models/currency.dart';
import 'package:moolax/business_logic/models/rate.dart';

import 'currency_service.dart';

// This class is just used temporarily during the tutorial so that the app can
// run without crashing before the WebApi service is finished.
class CurrencyServiceFake implements CurrencyService {

  @override
  Future<List<Rate>> getAllExchangeRates({String base}) async {
    return [];
  }

  @override
  Future<List<Currency>> getFavoriteCurrencies() async {
    return [];
  }

  @override
  Future<void> saveFavoriteCurrencies(List<Currency> data) async {

  }
}
