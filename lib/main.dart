import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:blink_application/repository/api_service.dart';
import 'package:blink_application/repository/bus_route_stop_data.dart';
import 'package:blink_application/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blink_application/repository/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'util/global_contans.dart';
import 'models/location_model.dart';
import 'models/user_model.dart';
import 'package:geolocator/geolocator.dart';

void main()  {
  Fluttertoast.showToast;
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

    WidgetsFlutterBinding.ensureInitialized();

  }

  // Method to handle successful login attempt
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
//
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final isAuthenticated = snapshot.data ?? false;
          this.isAuthenticated = isAuthenticated;
          logger.d('isAuthenticated $isAuthenticated');
          if (this.isAuthenticated) {
            return FutureBuilder(
                future: _initLoggedInUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final loggedInUser = snapshot.data;

                    logger.d('home isInitUserSuccessful $loggedInUser');
                    if(loggedInUser != null){
                      this.loggedInUser = loggedInUser;
                      _initDriverActivity();

                      return MaterialApp(
                          title: 'BLink',
                          initialRoute: '/',
                          routes: {
                            '/': (context) => isAuthenticated ? NavScreen(loggedInUser: loggedInUser, onLogout: onLogout) : SplashScreen(),
                            '/login': (context) => LoginScreen(onLoginSuccess: onLoginSuccess),
                            '/register': (context) => RegistrationScreen(),
                            '/search': (context) => SearchScreen()
                          },
                          navigatorObservers: [MyNavigatorObserver()],
                          theme: ThemeData(
                            primarySwatch: Colors.orange,
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            textTheme: GoogleFonts.rubikTextTheme()
                          )
                      );
                    } else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                });
          }else{
            return MaterialApp(
                title: 'BLink',
                initialRoute: '/',
                routes: {
                  '/': (context) => SplashScreen(),
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
        }
      },
    );
  }

  Future<User?> _initLoggedInUser() async {
    try{
      var loggedInUser = await getLoggedInUser();
      logger.d('login1 ${loggedInUser.toString()}');
      return loggedInUser;
    }catch(e){
      logger.d('_initLoggedInUser $e');
    }
  }

  void _initDriverActivity() async {
    logger.d('initDriverActivity ROLE ${loggedInUser?.role}');
    if(loggedInUser?.role == 'DRIVER'){
      currentUserId = loggedInUser?.userId;
      logger.d('initDriverActivity $currentUserId | $currentBusId');

      await AndroidAlarmManager.initialize();
      logger.d('initDriverActivity driver alarm');
      await AndroidAlarmManager.periodic(Duration(seconds: 30), 0, _hitBusActivityCheck);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _hitBusActivityCheck() async {
    final DateTime now = DateTime.now();
    logger.d("[$now] Hello, world! This is a background task.");

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await ApiService.busActivityCheck(
        busId: currentBusId,
        userId: currentUserId,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString()
      );
      Fluttertoast.showToast(
        msg: "busActivityCheck success",
        toastLength: Toast.LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Where the toast should appear on the screen
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
      );
    } catch (e) {
      print('busActivityCheck failed: $e');
    }
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
