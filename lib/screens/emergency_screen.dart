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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Emergency Contacts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('Emergency Services - 911', style: TextStyle(fontSize: 18)),
              subtitle: Text('Call for emergency assistance', style: TextStyle(fontSize: 14)),
              leading: Icon(Icons.local_hospital, color: Colors.red, size: 36),
              onTap: () {
                // Action for calling emergency services
              },
            ),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('Fire Department - 112', style: TextStyle(fontSize: 18)),
              subtitle: Text('Call in case of fire emergency', style: TextStyle(fontSize: 14)),
              leading: Icon(Icons.fire_extinguisher, color: Colors.red, size: 36),
              onTap: () {
                // Action for calling fire department
              },
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Feedback',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('Submit Feedback', style: TextStyle(fontSize: 18)),
              subtitle: Text('Share your thoughts with us', style: TextStyle(fontSize: 14)),
              leading: Icon(Icons.feedback, color: Colors.orange, size: 36),
              onTap: () {
                // Action for submitting feedback
              },
            ),
          ),
        ],
      ),
    );
  }
}
