import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:get_storage/get_storage.dart'; 
import 'navbottom.dart'; 

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({Key? key}) : super(key: key);

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController(); 
  bool isLoading = false; // Status untuk indikator loading

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveNoteToSupabase() async {
    // Validasi input judul
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

      // 2. Simpan ke tabel 'isi_catatan'
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
      Get.offAll(() => bottomNavigationBar()); 
    } catch (e) {
      print('Error saving note: $e'); // Cetak error ke konsol untuk debugging
      String errorMessage = "Terjadi kesalahan saat menyimpan catatan.";
      if (e is PostgrestException) {
        errorMessage = "Error database: ${e.message}";
      } else if (e.toString().contains('duplicate key value violates unique constraint')) {
        errorMessage = "Judul catatan sudah ada. Gunakan judul lain.";
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', ''); // Hapus "Exception: "
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back(); 
          },
        ),
        title: Image.asset(
          'assets/IngetinPutih.png', 
          height: 30,
        ),
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            onPressed: isLoading ? null : saveNoteToSupabase, 
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Masukkan Judul',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(
              thickness: 1,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: noteController, 
                decoration: const InputDecoration.collapsed(
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