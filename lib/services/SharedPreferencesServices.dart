import 'package:shared_preferences/shared_preferences.dart';

import '../constants/SharedPreferencesConstants.dart';

class SharedPreferencesService {
  final SharedPreferences sharedPreferences;
  SharedPreferencesService(this.sharedPreferences);

  Future<bool> setUsername(String value) async {
    return sharedPreferences.setString(SharedPreferencesConstants.prefUsername, value);
  }

  Future<bool> setRole(String value) async {
    return sharedPreferences.setString(SharedPreferencesConstants.prefRole, value);
  }

  Future<bool> setIsLoggedIn(bool value) async {
    return sharedPreferences.setBool(SharedPreferencesConstants.prefIsLoggedIn, value);
  }

  String getUsername() {
    return sharedPreferences.getString(SharedPreferencesConstants.prefUsername) ?? "";
  }

  String getRole() {
    return sharedPreferences.getString(SharedPreferencesConstants.prefRole) ?? "";
  }

  bool getIsLoggedIn() {
    return sharedPreferences.getBool(SharedPreferencesConstants.prefIsLoggedIn) ?? false;
  }

  Future<bool> clear() async {
    return sharedPreferences.clear();
  }

}