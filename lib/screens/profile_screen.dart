import 'package:blink_application/res/colors.dart';
import 'package:flutter/material.dart';

import '../util/global_contans.dart';
import '../models/user_model.dart';
import '../repository/user_data.dart';


class ProfileScreen extends StatefulWidget {
  final User loggedInUser;
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.loggedInUser, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    var user = widget.loggedInUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.orangeSoft,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 100.0,
                    backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdT7Hx73xEUUnyzR3xQz0Mvwh0LQ6y4WVeptjHc_sluA&s'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0)),
                      ),
                      child: Text(
                        'Role: User',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: AppColors.teaBrown,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.teaBrown,
                  ),
                ),
                SizedBox(height: 5,)
              ],),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to edit profile screen
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: AppColors.teaBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 17),
                        SizedBox(width: 5.0),
                        Text('Edit Profile', style: TextStyle(fontSize: 13))
                      ],
                    ),
                  ),
                  SizedBox(width: 10.0),
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            content: Text('Sure you want to log out?', style: TextStyle(color: Colors.black, fontSize: 16),),
                            actions: [
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
                                      Navigator.of(context).pop(); // Close the dialog
                                      navigateToSplashScreen();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: Colors.orange,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text('Log Out'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, side: BorderSide(color: Colors.red), // Border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text('Sign out', style: TextStyle(fontSize: 13)),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
  void navigateToSplashScreen() {
    logger.d('navigateToSplashScreen');
    setLoginStatus(false);
    widget.onLogout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }


}
