import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.name,
    this.textColor = Colors.black,
    required this.btnColor,
    required this.onTap,
    this.widget,
  });

  final String name;
  final Color btnColor;
  final Color textColor;
  final VoidCallback onTap;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
        ),
        child: widget ??
            Text(
              name,
              style: TextStyle(fontSize: 18, color: textColor),
            ),
      ),
    );
  }
}
