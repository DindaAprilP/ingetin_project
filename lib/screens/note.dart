import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../widgets/navbottom.dart'; 

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController(); 
  bool isLoading = false; 

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveNoteToSupabase() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        "Gagal Menyimpan",
        "Judul catatan tidak boleh kosong.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true; 
    });

    try {
      final supabase = Supabase.instance.client;
      final User? currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        Get.snackbar(
          "Error",
          "Anda harus login untuk membuat catatan.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final List<Map<String, dynamic>> catatanResponse = await supabase
          .from('catatan')
          .insert({
            'id_pengguna': currentUser.id,
            'judul': titleController.text.trim(),
            'jenis_catatan': 'catatan', 
          })
          .select(); 

      if (catatanResponse.isEmpty) {
        throw Exception("Gagal membuat entri catatan utama.");
      }

      final String idCatatanBaru = catatanResponse[0]['id'];
      await supabase.from('isi_catatan').insert({
        'id_catatan': idCatatanBaru,
        'isi_konten': noteController.text.trim(),
      });

      Get.snackbar(
        "Berhasil",
        "Catatan berhasil disimpan!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const bottomNavigationBar()); 
    } catch (e) {
      print('Error saving note: $e'); 
      String errorMessage = "Terjadi kesalahan saat menyimpan catatan.";
      if (e is PostgrestException) {
        errorMessage = "Error database: ${e.message}";
      } else if (e.toString().contains('duplicate key value violates unique constraint')) {
        errorMessage = "Judul catatan sudah ada. Gunakan judul lain.";
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', ''); 
      }
      Get.snackbar(
        "Gagal Menyimpan",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Buat Catatan Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back(); 
          },
        ),
        actions: [
          IconButton(
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check, color: Colors.white),
            onPressed: isLoading ? null : saveNoteToSupabase, 
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan Judul',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: noteController, 
                decoration: InputDecoration.collapsed(
                  hintText: 'Ketik catatan...',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}