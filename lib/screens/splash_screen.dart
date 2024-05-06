import 'package:blink_application/res/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Center(
            child: Image.asset('assets/images/logo_blink_app.png'),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(children: [
              SizedBox(
                child: Image.asset('assets/images/bus_splash_image.png'),
              ),
              Text(
                  "Linking Your Way Linking Your Day",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
              ),
            ],),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    navigateToLogin();
                  },
                  child: Text('Get Started', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Dont have an account?'),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        navigateToRegister();
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.orangeSoft,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),

    );
  }
  void navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }
}
