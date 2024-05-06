import 'package:blink_application/dialogs/success_dialog.dart';
import 'package:blink_application/res/colors.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repository/api_service.dart';
import '../util/global_contans.dart';

class FeedbackDialog extends StatefulWidget {
  final User loggedInUser;

  const FeedbackDialog({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {

  int _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Submit Feedback'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Rate your experience:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.star, color: _rating >= 1 ? AppColors.orangeSoft : Colors.grey),
                  onPressed: () => setState(() => _rating = 1),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: _rating >= 2 ? AppColors.orangeSoft : Colors.grey),
                  onPressed: () => setState(() => _rating = 2),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: _rating >= 3 ? AppColors.orangeSoft : Colors.grey),
                  onPressed: () => setState(() => _rating = 3),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: _rating >= 4 ? AppColors.orangeSoft : Colors.grey),
                  onPressed: () => setState(() => _rating = 4),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: _rating >= 5 ? AppColors.orangeSoft : Colors.grey),
                  onPressed: () => setState(() => _rating = 5),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Review cannot be empty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.orangeSoft)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _submitFeedback();
            }// Close the dialog

          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: AppColors.orangeSoft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('Submit'),
        ),
      ]
    );
  }

  void _submitFeedback() async {
    try {
      var jsonResponse = await ApiService.submitFeedback(
          userId: widget.loggedInUser.userId,
          feedback: _reviewController.text,
          rating: _rating
      );
      logger.d('_submitFeedback success $jsonResponse');
      handleSubmitFeedbackSuccess();

    } catch (e) {
      logger.d('_submitFeedback failed');
      handleSubmitFeedbackFailed(e.toString());
    }
  }

  void handleSubmitFeedbackSuccess() {
    Navigator.of(context).pop(); //
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showSuccessDialog('Feedback submitted!');
        }
    );
  }

  void handleSubmitFeedbackFailed(String error) {
    Navigator.of(context).pop(); //
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return showFailedDialog('Feedback submit error $error!');
        }
    );
  }

}
