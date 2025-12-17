import 'package:flutter/material.dart';

class UnitSettings extends ChangeNotifier {
  String _unit = 'km';

  String get unit => _unit;

  void changeUnit(String value) {
    _unit = value;
    notifyListeners();
  }
}