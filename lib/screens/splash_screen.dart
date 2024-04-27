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
          children: <Widget>[
            Text("Let's sign you in"),
            SizedBox(height: 16.0),
            SizedBox(
              child: Image.asset('assets/images/bus_splash_image.png'),
            ),
            Text("Linking Your Way Linking Your Day"),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  navigateToLogin();
                },
                child: const Text('Login'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Dont have an account'),
                GestureDetector(
                  onTap: () {
                    navigateToRegister();
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
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
