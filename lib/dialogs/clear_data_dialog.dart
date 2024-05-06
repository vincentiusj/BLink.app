import 'package:blink_application/dialogs/success_dialog.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repository/api_service.dart';
import '../res/colors.dart';
import '../util/global_contans.dart';


class ClearPersonalizationDialog extends StatefulWidget {
  final User loggedInUser;

  const ClearPersonalizationDialog({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<ClearPersonalizationDialog> createState() => _ClearPersonalizationDialogState();
}

class _ClearPersonalizationDialogState extends State<ClearPersonalizationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Text('Clear Favorites?', style: TextStyle(color: Colors.black, fontSize: 16),)
        ],
      ),
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
                _clearPersonalization();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: AppColors.orangeSoft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  void _clearPersonalization() async {
    try {
      var jsonResponse = await ApiService.clearAllFavorites(
          userId: widget.loggedInUser.userId
      );
      logger.d('_clearPersonalization success $jsonResponse');
      handleClearSuccess();

    } catch (e) {
      logger.d('_clearPersonalization failed');
      handleClearFailed(e.toString());
    }
  }

  void handleClearSuccess() {
    Navigator.of(context).pop(); //
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showSuccessDialog('Favorites Cleared!');
        }
    );
  }

  void handleClearFailed(String error) {
    Navigator.of(context).pop(); //
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showFailedDialog('Favorites Clearance Error  $error!');
        }
    );
  }


}
