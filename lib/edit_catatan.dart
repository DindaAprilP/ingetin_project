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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.catatan['judul']);
    _isiController = TextEditingController(text: widget.catatan['isi_catatan'] ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await supabase.from('catatan').update({
          'judul': _judulController.text.trim(),
        }).eq('id', widget.catatan['id']);

        final isiCatatanResponse = await supabase
            .from('isi_catatan')
            .select('id')
            .eq('id_catatan', widget.catatan['id'])
            .maybeSingle();

        if (isiCatatanResponse != null) {
          await supabase.from('isi_catatan').update({
            'isi_konten': _isiController.text.trim(),
          }).eq('id_catatan', widget.catatan['id']);
        } else {
          await supabase.from('isi_catatan').insert({
            'id_catatan': widget.catatan['id'],
            'isi_konten': _isiController.text.trim(),
          });
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          Get.back(result: true);
          Get.snackbar(
            "Sukses",
            "Catatan berhasil diperbarui",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      } catch (e) {
        print('Error updating catatan: $e');
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          Get.snackbar(
            "Gagal",
            "Tidak dapat menyimpan perubahan: ${e.toString()}",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Catatan"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _simpanPerubahan,
                  icon: Icon(Icons.check),
                  tooltip: 'Simpan Perubahan',
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                enabled: !_isLoading,
              ),
              SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _isiController,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !_isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}