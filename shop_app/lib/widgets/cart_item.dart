import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cart;
  final String productId;

  const CartItemWidget(this.cart, this.productId);

  @override
  Widget build(BuildContext context) {
    const margin = const EdgeInsets.symmetric(
      vertical: 4,
      horizontal: 15,
    );

    return Dismissible(
      key: ValueKey(cart.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: margin,
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: margin,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: FittedBox(
                  child: Text('\$${cart.price}'),
                ),
              ),
            ),
            title: Text(cart.title),
            subtitle: Text('Total: \$${cart.price * cart.quantity}'),
            trailing: Text('${cart.quantity}x'),
          ),
        ),
      ),
    );
  }
}