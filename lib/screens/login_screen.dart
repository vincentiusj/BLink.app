import 'package:blink_application/repository/user_data.dart';
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
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser(void Function() navigateToHome) async {
    try {
      var jsonResponse = await ApiService.loginUser(
        emailOrPhone: _emailOrPhoneController.text,
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
      // Login failed
      print('Login failed: $e');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Let's sign you in"),
              SizedBox(height: 16.0),
              _buildTextInput("Full Name", _emailOrPhoneController),
              _buildTextInput("Password", _passwordController),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _loginUser((){
                        navigateToHome();
                      });
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}