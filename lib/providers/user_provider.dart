import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // This holds the logged-in user's data
  Map<String, dynamic>? _currentUser;

  // This is a "getter" that other widgets can use to read the user data
  Map<String, dynamic>? get user => _currentUser;

  // This is for the log a user in
  void login(Map<String, dynamic> user) {
    _currentUser = user;
    // This tells all listening widgets to rebuild.
    notifyListeners();
  }

  // This is for updating the user's information
  void updateUser(Map<String, dynamic> updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // log out
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}