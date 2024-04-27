import 'package:shared_preferences/shared_preferences.dart';

import '../models/GlobalConstants.dart';

Future<void> storeLoggedInUserKey(String userId, String role) async {
  print('storeLoggedInUserKey $userId | $role');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setString('role', role);
}

Future<Map<String, String?>> getLoggedInUserKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final role = prefs.getString('role');
  return {'userId': userId, 'role': role};
}

Future<bool> checkLoginStatus() async {
  logger.t('checkLoginStatus');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isAuthenticated') ?? false;
}

Future<void> setLoginStatus(bool isAuthenticated) async {
  logger.t('setLoginStatus');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAuthenticated', isAuthenticated);
}