import 'dart:convert';
import 'package:flutter/material.dart';
import '../repository/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _registerUser(void Function() navigateToHome) async {
    try {
      await ApiService.registerUser(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        password: _passwordController.text,
      );
      // Registration successful
      navigateToHome();
      print('Registration successful');
    } catch (e) {
      // Registration failed
      print('Registration failed: $e');
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
              Text("Create a new account"),
              SizedBox(height: 16.0),
              _buildTextInput("Full Name", _fullNameController),
              _buildTextInput("Email", _emailController),
              _buildTextInput("Phone Number", _phoneNumberController),
              _buildTextInput("Password", _passwordController),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser(() {
                        navigateToHome();
                      });
                    }
                  },
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                filled: true,
                fillColor: Colors.amber),
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

  void navigateToHome(){
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
