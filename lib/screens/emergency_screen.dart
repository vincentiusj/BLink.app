import 'package:flutter/material.dart';

import '../models/user_model.dart';


class EmergencyScreen extends StatefulWidget {
  final User? loggedInUser;

  const EmergencyScreen({Key? key, this.loggedInUser}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Image.asset('assets/images/logo_blink_app.png'),
        ),
      ),
    );
  }
}
