import 'package:flutter/material.dart';

class AddNotesPage extends StatelessWidget {
  const AddNotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller untuk input (bisa digunakan nanti saat simpan ke database)
    final TextEditingController titleController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Image.asset(
          'assets/IngetinPutih.png', // Ganti sesuai lokasi gambar "Inget.in"
          height: 30,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Di sini nanti bisa tambah fungsi simpan ke database
              String title = titleController.text;
              String note = noteController.text;
              print("Judul: $title");
              print("Catatan: $note");
            },
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
