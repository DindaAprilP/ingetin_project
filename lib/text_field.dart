import 'package:flutter/material.dart';

class TextIsi extends StatelessWidget {
  const TextIsi({
    super.key,
    this.labelText,
    this.radius,
    this.iconData,
    });

    final String? labelText;
    final double? radius;
    final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        fillColor: Colors.orange[700],
        labelText: labelText,
        hintText: "Masukkan $labelText",
        prefixIcon: Icon(iconData ?? Icons.email_outlined)
      ),
    );
  }
}