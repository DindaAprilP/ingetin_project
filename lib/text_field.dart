import 'package:flutter/material.dart';

class TextIsi extends StatelessWidget {
  const TextIsi({
    super.key,
    this.controller, 
    this.labelText,
    this.radius,
    this.iconData,
    this.obscureText = false, 
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  final TextEditingController? controller;
  final String? labelText;
  final double? radius;
  final IconData? iconData;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: Colors.orange[700],
        labelText: labelText,
        hintText: "Masukkan $labelText",
        prefixIcon: Icon(iconData ?? Icons.email_outlined),
        suffixIcon: suffixIcon != null 
          ? IconButton(
              onPressed: onSuffixIconPressed,
              icon: Icon(suffixIcon),
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 8.0),
          borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
        ),
      ),
    );
  }
}