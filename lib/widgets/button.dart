import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String description;
  final void Function()? onPressed;

  const MyButton(
      {required this.description, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(description),
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white),
    );
  }
}
