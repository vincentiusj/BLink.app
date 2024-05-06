import 'package:flutter/material.dart';

Widget showFailedDialog(String errorMessage){
  return AlertDialog(
    title: Icon(Icons.error, color: Colors.redAccent, size: 30),
    content: Text(errorMessage),
  );
}

Widget showSuccessDialog(String errorMessage){
  return AlertDialog(
    title: Icon(Icons.check_circle, color: Colors.green, size: 30),
    content: Text(errorMessage),
  );
}