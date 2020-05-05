import 'package:flutter/foundation.dart';
import 'package:shopapp/providers/product.dart';
import 'package:shopapp/services/storage_service.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final storage = StorageService();

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return items.where((p) => p.isFavorite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((p) => p.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    _items = await storage.fetchProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {

    final id = await storage.saveProduct(product);

    final newProduct = Product(
      id: id,
      title: product.title,
      description: product.description,
      imageUrl: product.imageUrl,
      price: product.price,
    );

    _items.add(newProduct);
    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) {
    final oldProductIndex = _items.indexWhere((p) => p.id == id);
    _items[oldProductIndex] = newProduct;
    notifyListeners();
  }

  void deleteProduct(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}