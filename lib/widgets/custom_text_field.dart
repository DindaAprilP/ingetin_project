import 'package:flutter/material.dart';

class TextIsi extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? iconData;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator; 

  const TextIsi({
    super.key,
    required this.controller,
    required this.labelText,
    this.iconData,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator, 
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: iconData != null ? Icon(iconData) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}