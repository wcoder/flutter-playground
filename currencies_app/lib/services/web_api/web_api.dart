import 'package:moolax/business_logic/models/rate.dart';

// This is the contract that all WebApi services must follow. Using an abstract
// class like this allows you to swap concrete implementations. This is useful
// for separating architectural layers. It also makes testing and development
// easier because you can provide a mock implementation or fake data.
abstract class WebApi {
  Future<List<Rate>> fetchExchangeRates();
}