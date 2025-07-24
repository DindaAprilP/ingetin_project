import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddToDoPage extends StatefulWidget {
  const AddToDoPage({super.key});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final TextEditingController titleController = TextEditingController();
  final List<TextEditingController> itemControllers = List.generate(3, (_) => TextEditingController());
  final List<bool> isChecked = [false, false, false];
  
  bool _isLoading = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fungsi untuk menyimpan to-do list ke database
  Future<void> _saveToDoList() async {
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('Judul tidak boleh kosong', Colors.red);
      return;
    }

    // Validasi apakah ada item yang diisi
    bool hasItems = itemControllers.any((controller) => controller.text.trim().isNotEmpty);
    if (!hasItems) {
      _showSnackBar('Minimal satu item harus diisi', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil user ID dari auth
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _showSnackBar('Pengguna belum login', Colors.red);
        return;
      }

      // 1. Insert ke tabel catatan
      final catatanResponse = await _supabase
          .from('catatan')
          .insert({
            'id_pengguna': user.id,
            'judul': titleController.text.trim(),
            'jenis_catatan': 'tugas',
          })
          .select('id')
          .single();

      final String catatanId = catatanResponse['id'];

      // 2. Insert item-item tugas ke tabel item_tugas
      List<Map<String, dynamic>> itemsToInsert = [];
      for (int i = 0; i < itemControllers.length; i++) {
        String itemText = itemControllers[i].text.trim();
        if (itemText.isNotEmpty) {
          itemsToInsert.add({
            'id_catatan': catatanId,
            'teks_tugas': itemText,
            'sudah_selesai': isChecked[i],
            'urutan': i,
          });
        }
      }

      if (itemsToInsert.isNotEmpty) {
        await _supabase.from('item_tugas').insert(itemsToInsert);
      }

      // Tampilkan pesan sukses
      _showSnackBar('To-Do List berhasil disimpan!', Colors.green);

      // Kembali ke halaman sebelumnya
      Navigator.pop(context, {
        'success': true,
        'catatan_id': catatanId,
        'judul': titleController.text.trim(),
      });

    } catch (error) {
      print('Error menyimpan to-do list: $error');
      _showSnackBar('Gagal menyimpan to-do list: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'To Do List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: _saveToDoList,
                  tooltip: 'Simpan To-Do List',
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan Judul',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: titleController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Daftar Item',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked[index],
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              isChecked[index] = value!;
                            });
                          },
                          shape: const CircleBorder(),
                        ),
                        Expanded(
                          child: TextField(
                            controller: itemControllers[index],
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'Masukkan list item ${index + 1}',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Menyimpan to-do list...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

// Service class untuk operasi database to-do list
class ToDoService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan semua to-do list pengguna
  static Future<List<Map<String, dynamic>>> getUserTodoLists() async {
    try {
      final response = await _supabase
          .from('catatan')
          .select('''
            id,
            judul,
            dibuat_pada,
            diperbarui_pada,
            item_tugas(
              id,
              teks_tugas,
              sudah_selesai,
              urutan
            )
          ''')
          .eq('jenis_catatan', 'tugas')
          .order('dibuat_pada', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error getting todo lists: $error');
      rethrow;
    }
  }

  // Mendapatkan detail to-do list berdasarkan ID
  static Future<Map<String, dynamic>?> getTodoListById(String catatanId) async {
    try {
      final response = await _supabase
          .from('catatan')
          .select('''
            id,
            judul,
            dibuat_pada,
            diperbarui_pada,
            item_tugas(
              id,
              teks_tugas,
              sudah_selesai,
              urutan
            )
          ''')
          .eq('id', catatanId)
          .eq('jenis_catatan', 'tugas')
          .single();

      return response;
    } catch (error) {
      print('Error getting todo list by ID: $error');
      return null;
    }
  }

  // Update status item tugas
  static Future<bool> updateTaskStatus(String itemId, bool isCompleted) async {
    try {
      await _supabase
          .from('item_tugas')
          .update({'sudah_selesai': isCompleted})
          .eq('id', itemId);
      return true;
    } catch (error) {
      print('Error updating task status: $error');
      return false;
    }
  }

  // Hapus to-do list
  static Future<bool> deleteTodoList(String catatanId) async {
    try {
      await _supabase
          .from('catatan')
          .delete()
          .eq('id', catatanId);
      return true;
    } catch (error) {
      print('Error deleting todo list: $error');
      return false;
    }
  }

  // Update item tugas
  static Future<bool> updateTask(String itemId, String newText) async {
    try {
      await _supabase
          .from('item_tugas')
          .update({'teks_tugas': newText})
          .eq('id', itemId);
      return true;
    } catch (error) {
      print('Error updating task: $error');
      return false;
    }
  }
}