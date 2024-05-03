import 'package:blink_application/models/transaction_model.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/screens/screens.dart';
import 'package:blink_application/screens/stops_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../models/user_model.dart';
import '../repository/api_service.dart';

class NavScreen extends StatefulWidget {
  final User loggedInUser;
  final VoidCallback onLogout;

  const NavScreen({Key? key, required this.loggedInUser, required this.onLogout}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;
  bool _tappedIn = false;

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Image.asset('assets/images/logo_blink_app.png'),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(loggedInUser: widget.loggedInUser),
          const StopsScreen(),
          const EmergencyScreen(),
          ProfileScreen(loggedInUser: widget.loggedInUser, onLogout: widget.onLogout)
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: AppColors.orangeSoft,
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
                actionsAlignment: MainAxisAlignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                title: Column(children: [Text('Confirmation')],),
                content: Center(heightFactor: 0.5, child: _tappedIn ? Text('TAP OUT NOW?') : Text('TAP IN')),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add your confirmation logic here
                          // _tapIn();
                          _startNFCReading();
                          setState(() {
                            _tappedIn = !_tappedIn;
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Yes'),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
        backgroundColor: _tappedIn? AppColors.teaBrown : AppColors.orangeSoft,
        child: const Icon(Icons.bus_alert),
        splashColor:  !_tappedIn? AppColors.teaBrown : AppColors.orangeSoft,
        shape: CircleBorder()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //We first check if NFC is available on the device.
      if (isAvailable) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Process NFC tag, When an NFC tag is discovered, print its data to the console.
            debugPrint('NFC Tag Detected: ${tag.data}');
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
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
