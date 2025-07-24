import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:ingetin_project/screens/edit_catatan_screen.dart'; 
import 'package:ingetin_project/services/dashboard_service.dart'; 
import 'package:ingetin_project/widgets/catatan_list_item.dart'; 
import 'package:ingetin_project/widgets/catatan_detail_bottom_sheet.dart'; 
import 'package:ingetin_project/models/schedule_models.dart';

class BerandaScreen extends StatefulWidget { 
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final DashboardService _dashboardService = DashboardService(); 
  List<Map<String, dynamic>> catatan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCatatan();
  }

  Future<void> loadCatatan() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          catatan = [];
          isLoading = false;
        });
        Get.snackbar(
          "Autentikasi Diperlukan",
          "Anda perlu login untuk melihat catatan.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final fetchedCatatan = await _dashboardService.getCatatanForUser(userId);

      setState(() {
        catatan = fetchedCatatan;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error in BerandaScreen loadCatatan: $error");
    }
  }

  Future<void> _hapusCatatan(String idCatatan, String judul) async {
    bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Catatan'),
          content: Text('Apakah Anda yakin ingin menghapus "$judul"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      try {
        await _dashboardService.deleteCatatan(idCatatan);

        Get.snackbar(
          "Berhasil",
          "Catatan berhasil dihapus",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        loadCatatan();
      } catch (error) {
        Get.snackbar(
          "Error",
          "Gagal menghapus catatan: ${error.toString()}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _navigateToEdit(Map<String, dynamic> item) async {
    final Catatan? catatanModel = item['id'] != null ? Catatan.fromMap(item) : null;

    final result = await Get.to(() => EditCatatanScreen(catatan: catatanModel));
    if (result == true) {
      loadCatatan();
    }
  }

  void _lihatDetailCatatan(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CatatanDetailBottomSheet(
          item: item,
          onEditCallback: (selectedItem) {
            _navigateToEdit(selectedItem);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset(
          'assets/tugas', 
          height: 30,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : catatan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          "assets/berandaKosong.png", // Sesuaikan path asset Anda
                          width: 120,
                          height: 120,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Belum Ada Catatan"),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadCatatan,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: catatan.length,
                    itemBuilder: (context, index) {
                      final item = catatan[index];
                      return CatatanListItem(
                        item: item,
                        onTap: () => _lihatDetailCatatan(item),
                        onDelete: _hapusCatatan,
                        onEdit: _navigateToEdit,
                      );
                    },
                  ),
                ),
    );
  }
}