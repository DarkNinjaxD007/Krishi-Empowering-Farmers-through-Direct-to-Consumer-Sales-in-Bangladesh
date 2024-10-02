import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _sharedPreferences;
  static const String USERNAME= "USERNAME";
  static const String PASSWORD= "PASSWORD";
  static const String USER_ID= "USERID";

  AppPreferences(this._sharedPreferences);


  Future<void> saveCredentials(String userName, String password) async {
    await _sharedPreferences.setString(USERNAME, userName);
    await _sharedPreferences.setString(PASSWORD, password);
  }

  String? getUserName()  {
    String? username = _sharedPreferences.getString(USERNAME);
    return username;
  }

  String?  getUserPassword() {
    String? password = _sharedPreferences.getString(PASSWORD);
    return password;
  }

  Future<void> storeUserId(String userId) async{
    await _sharedPreferences.setString(USER_ID, userId);
  }



}