import 'package:blink_application/repository/api_service.dart';
import 'package:blink_application/repository/bus_route_stop_data.dart';
import 'package:blink_application/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blink_application/repository/user_data.dart';

import 'models/GlobalConstants.dart';
import 'models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false;
  User? loggedInUser;

  @override
  initState()  {
    // TODO: implement initState
    super.initState();

    initBusRouteStopData();

    _initLoggedInUser();

    WidgetsFlutterBinding.ensureInitialized();
    checkLoginStatus().then((isAuthenticated) {
      setState(() {
        print('checkLoginStatus $isAuthenticated');
        this.isAuthenticated = isAuthenticated;
      });
    });
  }

  // Method to handle successful login
  void onLoginSuccess() {
    logger.d('onLoginSuccess');
    setState(() {
      isAuthenticated = true;
    });
  }

  void onLogout() {
    logger.d('onLogout');
    setState(() {
      isAuthenticated = false;
    });
  }

// This widget is the root  of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLink',
      initialRoute: '/',
      routes: {
        '/': (context) => isAuthenticated ? NavScreen(loggedInUser: loggedInUser!, onLogout: onLogout) : SplashScreen(),
        '/login': (context) => LoginScreen(onLoginSuccess: onLoginSuccess),
        '/register': (context) => RegistrationScreen(),
        '/search': (context) => SearchScreen()
      },
      navigatorObservers: [MyNavigatorObserver()],
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat',
      )
    );
  }

  Future<User?> _getUserInfo() async {
    Map<String, String?> loggedInUserKey = await getLoggedInUserKey();
    print('login $loggedInUserKey');
    try {
      var jsonResponse = await ApiService.getUserInfo(
        userId: loggedInUserKey['userId']!,
        role: loggedInUserKey['role']!,
      );
      return User.fromJson(jsonResponse);
    } catch (e) {
      print('Get user info failed: $e');
    }
  }

  _initLoggedInUser() async {
    loggedInUser = await _getUserInfo();
  }
}



class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Hide the navigation bar if the current route is the login or registration screen
    if (route.settings.name == '/' ||
        route.settings.name == '/login' ||
        route.settings.name == '/register') {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Show the navigation bar when navigating back from the login or registration screen
    if (previousRoute?.settings.name == '/' ||
        previousRoute?.settings.name == '/login' ||
        previousRoute?.settings.name == '/register') {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
