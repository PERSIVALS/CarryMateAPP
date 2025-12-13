import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseService _db;
  CartProvider(this._db);

  List<CartItem> get carts => _db.carts;

  void addCart(CartItem item) {
    _db.addCart(item);
    notifyListeners();
  }

  void removeCart(String name) {
    _db.removeCart(name);
    notifyListeners();
  }

  void updateCart(String name, {int? battery, double? range, double? weight}) {
    _db.updateCart(name, battery: battery, range: range, weight: weight);
    notifyListeners();
  }
}