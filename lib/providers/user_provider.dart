import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;
  UserProvider(this._db);

  UserProfile get profile => _db.userProfile;

  void updateSteps(int steps) {
    _db.updateSteps(steps);
    notifyListeners();
  }

  void updateCalories(int calories) {
    _db.updateCalories(calories);
    notifyListeners();
  }
}