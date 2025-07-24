import 'package:flutter/material.dart';

class CatatanFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const CatatanFormWidget({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Isi Catatan',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        enabled: !isLoading,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Isi catatan tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}