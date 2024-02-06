import 'package:flutter/material.dart';

class ExpenseTextField extends StatelessWidget {
  const ExpenseTextField({
    super.key,
    required this.label,
    required this.iconData,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  final String label;
  final IconData iconData;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          suffixIcon: Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
