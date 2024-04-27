import 'package:blink_application/models/transaction_model.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/screens/screens.dart';
import 'package:blink_application/screens/stops_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/user_model.dart';
import '../repository/api_service.dart';
import '../repository/user_data.dart';

class NavScreen extends StatefulWidget {
  final User loggedInUser;

  const NavScreen({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;
  bool _tappedIn = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StopsScreen(),
    // const EmergencyScreen(),
    // const ProfleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.amber,
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              color: _selectedIndex == 0 ? Colors.white : AppColors.teaBrown,
            ),
            IconButton(
              icon: Icon(Icons.route),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              color: _selectedIndex == 1 ? Colors.white : AppColors.teaBrown,
            ),
            SizedBox(width: 40.0),
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;

                });
              },
              color: _selectedIndex == 2 ? Colors.white : AppColors.teaBrown,

            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              color: _selectedIndex == 3 ? Colors.white : AppColors.teaBrown,

            ),
          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: _tappedIn ? Text('Successful Tap In!\n Tap out now?') : Text('TsourAP IN'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      // Add your confirmation logic here
                      // _tapIn();
                      setState(() {
                        _tappedIn = !_tappedIn;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: _tappedIn? Colors.cyan : Colors.orangeAccent,
        child: const Icon(Icons.bus_alert),
        splashColor:  !_tappedIn? Colors.cyan : Colors.orangeAccent,
        shape: CircleBorder()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Future<Tap?> _tapIn() async {
    print('login ${widget.loggedInUser}');
    try {
      var jsonResponse = await ApiService.tapIn(
        userId: widget.loggedInUser.userId,
        busId: '',
        role: widget.loggedInUser.role ?? 'PASSENGER',
      );
      return Tap.fromJson(jsonResponse);
    } catch (e) {
      print('Get user info failed: $e');
    }
  }


}
