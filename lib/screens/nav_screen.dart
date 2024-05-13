import 'package:blink_application/models/transaction_model.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/screens/screens.dart';
import 'package:blink_application/screens/stops_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../models/user_model.dart';
import '../repository/api_service.dart';
import '../util/global_contans.dart';

class NavScreen extends StatefulWidget {
  final User loggedInUser;
  final VoidCallback onLogout;

  const NavScreen({Key? key, required this.loggedInUser, required this.onLogout}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _tappedIn = false;
  String? _transactionId;
  late AnimationController _animationController;
  static const platform = MethodChannel('tap_bus_channel');
  String _nfcData = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPlatformState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == 'onNfcDetected') {
      setState(() {
        _nfcData = call.arguments;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Image.asset('assets/images/logo_blink_app.png'),
        ),
      ),
      resizeToAvoidBottomInset: true,
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
        padding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        shape: CircularNotchedRectangle(),
        color: AppColors.orangeSoft,
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(width: 0.2,),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  color: _selectedIndex == 0 ? Colors.white : AppColors.teaBrown,
                ),
                Text('Home', style: TextStyle(fontSize: 10, color: AppColors.teaBrown),)
              ],
            ),
            SizedBox(width: 0.2,),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.route),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  color: _selectedIndex == 1 ? Colors.white : AppColors.teaBrown,
                ),
                Text('Route', style: TextStyle(fontSize:10, color: AppColors.teaBrown)),
              ],
            ),
            SizedBox(width: 60.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;

                    });
                  },
                  color: _selectedIndex == 2 ? Colors.white : AppColors.teaBrown,

                ),
                Text('Emergency', style: TextStyle(fontSize: 10, color: AppColors.teaBrown))
              ],
            ),
            SizedBox(width: 0.2,),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  color: _selectedIndex == 3 ? Colors.white : AppColors.teaBrown,
                ),
                Text('Profile', style: TextStyle(fontSize: 10, color: AppColors.teaBrown))
              ],
            ),
            SizedBox(width: 0.2,),

          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startNFCReading();
          _showNFCDialog();
        },
        backgroundColor: _tappedIn? AppColors.teaBrown : AppColors.orangeSoft,
        child: const Icon(Icons.bus_alert),
        splashColor:  !_tappedIn? AppColors.teaBrown : AppColors.orangeSoft,
        shape: CircleBorder()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showNFCDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              width: MediaQuery.of(context).size.width * 0.6,
              height: 250.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2.0 * -0.5,
                        child: Icon(
                          Icons.speaker_phone,
                          size: 64.0,
                          color: AppColors.orangeSoft,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    !_tappedIn ? 'Tap in to bus..' : 'Tap out from bus',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _startNFCReading() async {
    String? busId;
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //We first check if NFC is available on the device.
      if (isAvailable) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {

            // Process NFC tag, When an NFC tag is discovered, print its data to the console
            Ndef? ndef = Ndef.from(tag);
            logger.d('NFC detected $ndef');

            var message = ndef?.cachedMessage;
            for(var record in message!.records){
              var stringPayload = String.fromCharCodes(record.payload).substring(3);
              logger.d('NFC detected $stringPayload');
              busId = stringPayload;
            }
            await NfcManager.instance.stopSession();
            !_tappedIn ? _tapIn(busId) : _tapOut(busId, _transactionId!);
            Navigator.pop(context);
            setState(() {
              _tappedIn = !_tappedIn;
            });;
          },
        );
        return busId;
      } else {
        logger.d('NFC not available.');
      }
    } catch (e) {
      logger.d('Error reading NFC: $e');
    }
  }

  void showTapSuccessDialog(String tapType){
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                Align(
                  alignment: Alignment.center,
                  child: Text('Successful $tapType', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<Tap?> _tapIn(String? busId) async {
    print('_tapIn ${widget.loggedInUser}');
    try {
      var jsonResponse = await ApiService.tapIn(
        userId: widget.loggedInUser.userId,
        busId: busId ?? '',
        role: widget.loggedInUser.role ?? 'PASSENGER',
      );
      logger.d('_tapIn successful: $jsonResponse');
      showTapSuccessDialog('Tap In');
      var tapData = Tap.fromJson(jsonResponse);
      _transactionId = tapData.transactionId;
      return tapData;
    } catch (e) {
      print('_tapIn failed: $e');
    }
  }

  Future<Tap?> _tapOut(String? busId, String transactionId) async {
    print('_tapOut ${widget.loggedInUser}');
    try {
      var jsonResponse = await ApiService.tapOut(
        userId: widget.loggedInUser.userId,
        busId: busId ?? '',
        role: widget.loggedInUser.role ?? 'PASSENGER',
        transactionId: transactionId,
      );
      showTapSuccessDialog('Tap Out');

      logger.d('_tapOut successful: $jsonResponse');
      return Tap.fromJson(jsonResponse);
    } catch (e) {
      print('_tapOut failed: $e');
    }
  }


}
