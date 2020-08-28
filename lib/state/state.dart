import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StateModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  dynamic _userInfo;

  /// An unmodifiable view of the items in the cart.
  dynamic get userInfo => _userInfo;

  void setUserInfo(dynamic userInfo) async {
    final prefs = await SharedPreferences.getInstance();

    if (userInfo == null) {
      print('remove storage: userInfo');
      prefs.remove('userInfo');
    } else {
      print('set storage: userInfo');
      prefs.setString('userInfo', jsonEncode(userInfo));
    }
    _userInfo = userInfo;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}