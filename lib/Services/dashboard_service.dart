import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart'; 

class DashboardService {
  final SupabaseClient _supabase;

  DashboardService() : _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCatatanForUser(String userId) async {
    try {
      final response = await _supabase
          .from('catatan_dengan_detail')
          .select()
          .eq('id_pengguna', userId)
          .order('diperbarui_pada', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      Get.snackbar(
        "Error Database",
        "Gagal memuat catatan: ${e.message}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }

  Future<void> deleteCatatan(String idCatatan) async {
    try {
      await _supabase.from('catatan').delete().eq('id', idCatatan);
    } on PostgrestException catch (e) {
      throw Exception("Gagal menghapus catatan dari database: ${e.message}");
    } catch (e) {
      throw Exception("Terjadi kesalahan saat menghapus catatan: ${e.toString()}");
    }
  }

  Future<List<Map<String, dynamic>>> getItemTugasForDetail(String idCatatan) async {
    try {
      final response = await _supabase
          .from('item_tugas')
          .select()
          .eq('id_catatan', idCatatan)
          .order('urutan');
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print("Error loading item tugas for detail: ${e.message}");
      return [];
    } catch (e) {
      print("Error loading item tugas for detail: ${e.toString()}");
      return [];
    }
  }
}