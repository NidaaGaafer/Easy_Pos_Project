import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputformatters;
  final TextInputType? keyboardType;
  final String label;

  const AppTextField(
      {required this.label,
      required this.controller,
      required this.validator,
      this.inputformatters,
      this.keyboardType,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters:inputformatters,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      autocorrect: true,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }
}
