import 'package:flutter/material.dart';
import 'package:shopapp/providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cart;

  const CartItemWidget(this.cart);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 15,
      ),
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
    );
  }
}