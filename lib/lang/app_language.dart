import 'package:flutter/material.dart';
import 'lang/eng.dart';
import 'lang/pl.dart';
import 'lang/fr.dart';

class AppLanguage extends ChangeNotifier {
  Map<String, String> _localizedStrings = eng;

  void changeLanguage(String code) {
    switch (code) {
      case 'pl':
        _localizedStrings = pl;
        break;
      case 'fr':
        _localizedStrings = fr;
        break;
      default:
        _localizedStrings = eng;
    }
    notifyListeners();
  }

  String t(String key) => _localizedStrings[key] ?? key;
}
