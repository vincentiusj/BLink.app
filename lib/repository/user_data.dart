import 'package:shared_preferences/shared_preferences.dart';

import '../util/global_contans.dart';
import '../models/user_model.dart';

Future<void> storeLoggedInUser(User user) async {
  print('storeLoggedInUserKey $user');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', user.userId);
  await prefs.setString('fullName', user.fullName);
  await prefs.setString('email', user.email);
  await prefs.setString('role', user.role);
}

Future<User> getLoggedInUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final fullName = prefs.getString('fullName');
  final email = prefs.getString('email');
  final role = prefs.getString('role');
  return User(userId: userId!, fullName: fullName!, email: email!, role: role!);
    // {'userId': userId, 'fullName''role': role,};
}

Future<bool> checkLoginStatus() async {
  logger.t('checkLoginStatus');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isAuthenticated') ?? false;
  // return false;
}

Future<void> setLoginStatus(bool isAuthenticated) async {
  logger.t('setLoginStatus $isAuthenticated');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAuthenticated', isAuthenticated);
}