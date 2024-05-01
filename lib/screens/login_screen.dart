import 'package:blink_application/repository/user_data.dart';
import 'package:blink_application/screens/registration_screen.dart';
import 'package:flutter/material.dart';

import '../models/GlobalConstants.dart';
import '../repository/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser(void Function() navigateToHome) async {
    try {
      var jsonResponse = await ApiService.loginUser(
        emailOrPhone: _emailController.text,
        password: _passwordController.text,
      );
      // Login successful
      // Navigate to Home Screen
      setState(() {
        storeLoggedInUserKey(jsonResponse['user_id'], jsonResponse['role']);
        navigateToHome();

        widget.onLoginSuccess();
      });
      // widget.onLoginSuccess();
      // navigateToHome();
      print('Login successful');
    } catch (e) {
      logger.d('login failed ${e.toString()}');
      showLoginErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Image.asset('assets/images/logo_blink_app.png'),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.orange), // Change border color here
                        ),
                      filled: true,
                      fillColor: Colors.orange[50]
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b', caseSensitive: false).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.orange), // Change border color here
                        ),

                      filled: true,
                      fillColor: Colors.orange[50]
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _loginUser((){
                          navigateToHome();
                        });
                      }
                    },
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          // Navigate to registration screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       flexibleSpace: Center(
  //         child: Image.asset('assets/images/logo_blink_app.png'),
  //       ),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text("Let's sign you in"),
  //             SizedBox(height: 16.0),
  //             _buildTextInput("Full Name", _emailController),
  //             _buildTextInput("Password", _passwordController),
  //             Center(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   if (_formKey.currentState!.validate()) {
  //                     _loginUser((){
  //                       navigateToHome();
  //                     });
  //                   }
  //                 },
  //                 child: const Text('Login'),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void navigateToHome() {
    // Perform login logic
    logger.d('navigateToHome');
    setLoginStatus(true);
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget _buildTextInput(String field, TextEditingController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                labelText: field,
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                // Border when the field is enabled
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue, width: 1.0),
                ),
                // Border when the field is focused
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red),
                ),
                // Border when the field has an error
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                filled: true,
                fillColor: Colors.amber
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter your $field';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 16.0)
      ],
    );
  }

  void showLoginErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed. Please check your credentials.'),
      ),
    );
    // Clear text fields
    _emailController.clear();
    _passwordController.clear();
  }
}