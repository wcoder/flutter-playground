import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopapp/providers/product.dart';

class StorageService {
  static const url = 'https://poc-flutter-shop.firebaseio.com/products.json';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      extractedData.forEach((productId, productData) {
        loadedProducts.insert(0, Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ));
      });

      return loadedProducts;

    } catch (e) {
      throw e;
    }
  }

  Future<String> saveProduct(Product product) async {
    try {
      final response = await http.post(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite,
      }));

      return json.decode(response.body)['name'];

    } catch (error) {
      print(error);
      throw error;
    }
  }
}