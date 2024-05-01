import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/GlobalConstants.dart';
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
      logger.d('Registration successful');
      navigateToHome();
    } catch (e) {
      // Registration failed
      logger.d('Registration failed: $e');
      showRegisterErrorMessage();
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
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Colors.orange[200]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange)
                      ),
                      filled: true,
                      fillColor: Colors.orange[50],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.orange), // Change border color here
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.orange[200]),
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
                      prefixIcon: Icon(Icons.lock, color: Colors.orange[200]),
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.orange[200]),
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
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerUser(() {
                          navigateToHome();
                        });
                      }
                    },
                    child: Text('Register', style: TextStyle(color: Colors.black87),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          // Navigate to login screen
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
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
            ),
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
  //             Text("Create a new account"),
  //             SizedBox(height: 16.0),
  //             _buildTextInput("Full Name", _fullNameController),
  //             _buildTextInput("Email", _emailController),
  //             _buildTextInput("Phone Number", _phoneNumberController),
  //             _buildTextInput("Password", _passwordController),
  //             Center(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   if (_formKey.currentState!.validate()) {
  //                     _registerUser(() {
  //                       navigateToHome();
  //                     });
  //                   }
  //                 },
  //                 child: const Text('Register'),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

  void showRegisterErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed. Please try again.'),
      ),
    );
    // Clear text fields
    _fullNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
  }
}
