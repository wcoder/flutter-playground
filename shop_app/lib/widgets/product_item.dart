import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/product.dart';
import '../routes.dart';

class ProductItem extends StatelessWidget {
  void _selectItem(BuildContext context, Product product) {
    Navigator.of(context).pushNamed(Routes.productDetail, arguments: product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => _selectItem(context, product),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(product.isFavorite
              ? Icons.favorite
              : Icons.favorite_border
            ),
            color: Theme.of(context).accentColor,
            onPressed: product.toggleFavoriteStatus,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
