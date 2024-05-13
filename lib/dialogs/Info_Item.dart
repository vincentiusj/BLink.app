import 'package:blink_application/res/colors.dart';
import 'package:flutter/material.dart';


class InfoItem extends StatelessWidget {
  final String label;
  final String value;

  InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.teaBrown.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.teaBrown,
          ),
        ),
      ],
    );
  }
}