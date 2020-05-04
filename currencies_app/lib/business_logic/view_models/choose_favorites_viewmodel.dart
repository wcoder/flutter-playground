import 'package:moolax/business_logic/models/currency.dart';
import 'package:moolax/business_logic/models/rate.dart';
import 'package:moolax/services/currency/currency_service.dart';
import 'package:moolax/business_logic/utils/iso_data.dart';
import 'package:moolax/services/service_locator.dart';

// 1
import 'package:flutter/foundation.dart';

// 2
class ChooseFavoritesViewModel extends ChangeNotifier {

  // 3
  final CurrencyService _currencyService = serviceLocator<CurrencyService>();

  List<FavoritePresentation> _choices = [];
  List<Currency> _favorites = [];

  // 4
  List<FavoritePresentation> get choices => _choices;

  void loadData() async {
    // ...

    // 5
    notifyListeners();
  }

  void toggleFavoriteStatus(int choiceIndex) {
    // ...

    // 5
    notifyListeners();
  }
}

class FavoritePresentation {
  final String flag;
  final String alphabeticCode;
  final String longName;
  bool isFavorite;

  FavoritePresentation(
      {this.flag, this.alphabeticCode, this.longName, this.isFavorite,});
}
