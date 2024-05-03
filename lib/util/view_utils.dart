import 'package:flutter/material.dart';

Widget _buildTextInput(String field, TextEditingController controller) {
  return Column(
    children: [
      SizedBox(
        width: double.infinity,
        height: 50,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
              labelText: field,
              labelStyle: TextStyle(color: Colors.wh),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
              // Border when the field is enabled
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
              // Border when the field is focused
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.red),
              ),
              // Border when the field has an error
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              filled: true,
              fillColor: Colors.amber
          ),
          validator: (value) {
            if (value == null) {
              return 'Please enter your $field';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: 16.0)
    ],
  );
}