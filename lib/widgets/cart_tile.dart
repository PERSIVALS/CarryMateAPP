import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartTile extends StatelessWidget {
  final CartItem cart;
  const CartTile({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cart.name),
      subtitle: Text('Battery: ${cart.battery}% | Range: ${cart.range}m'),
      trailing: Text('${cart.weight} kg'),
    );
  }
}