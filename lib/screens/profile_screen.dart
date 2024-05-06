import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blink_application/res/colors.dart';
import 'package:flutter/material.dart';

import '../dialogs/clear_data_dialog.dart';
import '../dialogs/success_dialog.dart';
import '../repository/api_service.dart';
import '../util/global_contans.dart';
import '../models/user_model.dart';
import '../repository/user_data.dart';
import '../dialogs/feedback_dialog.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class ProfileScreen extends StatefulWidget {
  final User loggedInUser;
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.loggedInUser, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    var user = widget.loggedInUser;

    logger.d('profile user ${user.profileImage} | $user');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: AppColors.orangeSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(user.role, style: TextStyle(color: AppColors.teaBrown)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Stack(
                    children: [
                      // CircleAvatar(
                      //   backgroundImage: NetworkImage(""),
                      //   radius: 50,
                      // ),
                      if (_imageBytes == null && user.profileImage != null)
                        CircleAvatar(
                          backgroundImage: MemoryImage(base64Decode(user.profileImage!)),
                          radius: 100,
                        ),
                      if (_imageBytes != null)
                        CircleAvatar(
                          backgroundImage: MemoryImage(_imageBytes!),
                          radius: 100,
                        ),
                      if(_imageBytes == null && user.profileImage == null)
                        CircleAvatar(
                          radius: 100.0,
                          backgroundImage: NetworkImage(""),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 20,
                        child: TextButton(
                          onPressed: (){
                            _showOptions(context);
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(Icons.mode_edit_outline_sharp, color: AppColors.orangeSoft,)
                          ),
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Column(children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: AppColors.teaBrown,
                      ),
                    ), // full name
                    SizedBox(height: 5,),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.teaBrown,
                      ),
                    ), // email
                    SizedBox(height: 5,)
                  ],),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
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
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Cancel', style: TextStyle(color: AppColors.orangeSoft)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        clearLoggedIUser();
                                        navigateToSplashScreen();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: AppColors.orangeSoft,
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
                      child: Icon(Icons.logout, color: Colors.white,),
                    ),
                  ),// sign out button
                  SizedBox(height: 10,),
                ],
              ),
            ),
            SizedBox(height: 10,),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                splashColor: AppColors.orangeSoft,
                visualDensity: VisualDensity(vertical: -3),
                title: Text('Submit Feedback', style: TextStyle(fontSize: 14)),
                subtitle: Text('Share your thoughts with us', style: TextStyle(fontSize: 11)),
                leading: Icon(Icons.feedback, color: AppColors.orangeSoft, size: 25),
                onTap: () {
                  // Action for submitting feedback
                  showSubmitFeedbackDialog();
                },
              ),
            ), // feedback
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                splashColor: AppColors.orangeSoft,
                visualDensity: VisualDensity(vertical: -3),
                title: Text('Clear Favorites', style: TextStyle(fontSize: 14)),
                subtitle: Text('Remove favorite places from your account', style: TextStyle(fontSize: 11)),
                leading: Icon(Icons.delete_sweep_rounded, color: AppColors.orangeSoft, size: 25),
                onTap: () {
                  showClearPersonalizationDialog();
                },
              ),
            ), // clear data
          ],
        )

      )
    );
  }

  void navigateToSplashScreen() {
    logger.d('navigateToSplashScreen');
    setLoginStatus(false);
    widget.onLogout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void showSubmitFeedbackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FeedbackDialog(loggedInUser: widget.loggedInUser);
      },
    );
    setState(() {

    });
  }

  void showClearPersonalizationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClearPersonalizationDialog(loggedInUser: widget.loggedInUser);
      },
    );
  }


  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a picture'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Select from gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              if (widget.loggedInUser.profileImage != null)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete profile picture'),
                  onTap: () {
                    // widget.onImageSelected(null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _editProfile() async {
    var user = widget.loggedInUser;
    try {
      var jsonResponse = await ApiService.editProfile(
        userId: user.userId,
        role: user.role,
        profileImage:  base64Encode(_imageBytes!)
      );
      logger.d('_clearPersonalization success $jsonResponse');
      handleEditProfileSuccess('Edit Profile Success');

    } catch (e) {
      logger.d('_clearPersonalization failed');
      handleEditProfileFailed(e.toString());
    }
  }

  void handleEditProfileSuccess(String message) async {
    // Navigator.of(context).pop();
    var user = widget.loggedInUser;
    user.profileImage = base64Encode(_imageBytes!);

    await clearLoggedIUser();
    await storeLoggedInUser(user);
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showSuccessDialog(message);
        }
    );
  }

  void handleEditProfileFailed(String message) {
    // Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showSuccessDialog(message);
        }
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _imageBytes  = bytes;
        _editProfile();
      });
    }
  }




}
