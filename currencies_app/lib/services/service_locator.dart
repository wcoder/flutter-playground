import 'package:get_it/get_it.dart';
import 'currency/currency_service.dart';
import 'currency/currency_service_fake.dart';
import 'storage/storage_service.dart';
import 'storage/storage_service_implementation.dart';
import '../business_logic/view_models/calculate_screen_viewmodel.dart';
import '../business_logic/view_models/choose_favorites_viewmodel.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {

  serviceLocator.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  serviceLocator.registerLazySingleton<CurrencyService>(() => CurrencyServiceFake());

  serviceLocator.registerFactory<CalculateScreenViewModel>(() => CalculateScreenViewModel());
  serviceLocator.registerFactory<ChooseFavoritesViewModel>(() => ChooseFavoritesViewModel());
}
