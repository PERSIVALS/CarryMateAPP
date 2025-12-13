import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';

class DatabaseService extends ChangeNotifier {
  final List<CartItem> _carts = [
    CartItem(name: 'Cart 1', battery: 80, range: 2.5, weight: 5.0),
    CartItem(name: 'Cart 2', battery: 60, range: 1.2, weight: 3.0),
    CartItem(name: 'Cart 3', battery: 95, range: 3.8, weight: 7.5),
  ];

  UserProfile _userProfile = UserProfile(
    name: 'Yoo Jae Suk',
    email: 'yoo@example.com',
    steps: 1200,
    calories: 300,
  );

  List<CartItem> get carts => List.unmodifiable(_carts);
  UserProfile get userProfile => _userProfile;

  void updateSteps(int steps) {
    _userProfile = _userProfile.copyWith(steps: steps);
    notifyListeners();
  }

  void updateCalories(int calories) {
    _userProfile = _userProfile.copyWith(calories: calories);
    notifyListeners();
  }

  void addCart(CartItem item) {
    _carts.add(item);
    notifyListeners();
  }

  void removeCart(String name) {
    _carts.removeWhere((cart) => cart.name == name);
    notifyListeners();
  }

  void updateCart(String name, {int? battery, double? range, double? weight}) {
    final index = _carts.indexWhere((cart) => cart.name == name);
    if (index != -1) {
      final old = _carts[index];
      _carts[index] = old.copyWith(
        battery: battery,
        range: range,
        weight: weight,
      );
      notifyListeners();
    }
  }
}