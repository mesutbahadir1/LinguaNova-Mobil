import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? _userId;

  int? get userId => _userId;

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void clearUserId() {
    _userId = null;
    notifyListeners();
  }
}
