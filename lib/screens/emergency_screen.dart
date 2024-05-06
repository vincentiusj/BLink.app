import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
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
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('Emergency Services - 119', style: TextStyle(fontSize: 18)),
              subtitle: Text('Call for ambulance and health emergency assistance', style: TextStyle(fontSize: 12)),
              leading: Icon(Icons.local_hospital, color: Colors.red, size: 36),
              onTap: () {
                // Action for calling emergency services
                _makeEmergencyCall('119');
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
              title: Text('Police Station - 110', style: TextStyle(fontSize: 18)),
              subtitle: Text('Call for emergency assistance', style: TextStyle(fontSize: 12)),
              leading: Icon(Icons.local_hospital, color: Colors.red, size: 36),
              onTap: () {
                // Action for calling emergency services
                _makeEmergencyCall('110');
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
              title: Text('Fire Department - 113', style: TextStyle(fontSize: 18)),
              subtitle: Text('Call in case of fire emergency', style: TextStyle(fontSize: 12)),
              leading: Icon(Icons.fire_extinguisher, color: Colors.red, size: 36),
              onTap: () {
                _makeEmergencyCall('113');
              },
            ),
          ),
          SizedBox(height: 32),

        ],
      ),
    );
  }

  void _makeEmergencyCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    print("Call status: $res");
  }
}
