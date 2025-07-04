import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCatatan extends StatefulWidget {
  final Map<String, dynamic> catatan;

  const EditCatatan({super.key, required this.catatan});

  @override
  State<EditCatatan> createState() => _EditCatatanState();
}

class _EditCatatanState extends State<EditCatatan> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.catatan['judul']);
    _isiController = TextEditingController(text: widget.catatan['isi_catatan']);
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from('catatan').update({
          'judul': _judulController.text,
          'isi_catatan': _isiController.text,
          'diperbarui_pada': DateTime.now().toIso8601String(),
        }).eq('id', widget.catatan['id']);

        Get.back();
        Get.snackbar(
          "Sukses",
          "Catatan berhasil diperbarui",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Gagal",
          "Tidak dapat menyimpan perubahan",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Catatan"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _isiController,
                decoration: InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _simpanPerubahan,
                icon: Icon(Icons.save),
                label: Text("Simpan"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
