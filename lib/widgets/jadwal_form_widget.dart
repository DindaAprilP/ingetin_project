import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:intl/intl.dart';

class JadwalFormWidget extends StatefulWidget {
  final TextEditingController deskripsiController;
  final TextEditingController tanggalController;
  final TextEditingController jamMulaiController;
  final TextEditingController jamSelesaiController;
  final bool isLoading;

  const JadwalFormWidget({
    super.key,
    required this.deskripsiController,
    required this.tanggalController,
    required this.jamMulaiController,
    required this.jamSelesaiController,
    required this.isLoading,
  });

  @override
  State<JadwalFormWidget> createState() => _JadwalFormWidgetState();
}

class _JadwalFormWidgetState extends State<JadwalFormWidget> {
  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? initialDate;
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.text);
      }
    } catch (e) {
      initialDate = DateTime.now();
    }
    initialDate ??= DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toString().split(' ')[0]; // Format YYYY-MM-DD
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? initialTime;
    try {
      if (controller.text.isNotEmpty) {
        final parts = controller.text.split(':');
        if (parts.length >= 2) {
          initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }
    initialTime ??= TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextFormField(
            controller: widget.tanggalController,
            decoration: const InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            enabled: !widget.isLoading,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Tanggal wajib diisi'
                : null,
            onTap: () => _pickDate(widget.tanggalController),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.jamMulaiController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  enabled: !widget.isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Jam mulai wajib diisi'
                      : null,
                  onTap: () => _pickTime(widget.jamMulaiController),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: widget.jamSelesaiController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  enabled: !widget.isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Jam selesai wajib diisi'
                      : null,
                  onTap: () => _pickTime(widget.jamSelesaiController),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextFormField(
              controller: widget.deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              enabled: !widget.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}