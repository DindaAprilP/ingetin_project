import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart'; 
import 'package:get_storage/get_storage.dart'; 

class AuthService {
  final SupabaseClient _supabase;

  AuthService() : _supabase = Supabase.instance.client;

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    if (username.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Semua field harus diisi",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception("Bidang input tidak boleh kosong");
    }

    if (username.trim().length > 50) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Username maksimal 50 karakter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception("Username terlalu panjang");
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username.trim())) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Username hanya boleh berisi huruf, angka, dan underscore",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception("Format username tidak valid");
    }

    if (password.length < 6) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Password minimal 6 karakter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception("Password terlalu pendek");
    }

    if (!GetUtils.isEmail(email.trim())) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Format email tidak valid",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception("Format email tidak valid");
    }

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'nama_pengguna': username.trim(), 
        },
      );

      if (response.user != null) {
        final box = GetStorage();
        box.write('user_id', response.user!.id);
        box.write('email', response.user!.email);
        box.write('username', username.trim());

        Get.snackbar(
          "REGISTER BERHASIL",
          "Akun berhasil dibuat!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception("Pendaftaran gagal: Pengguna tidak ditemukan setelah pendaftaran.");
      }
    } on AuthException catch (e) { 
      String errorMessage = "Terjadi kesalahan saat mendaftar: ${e.message}";
      if (e.message.contains('duplicate key value violates unique constraint')) {
         errorMessage = "Username sudah digunakan atau email sudah terdaftar.";
      } else if (e.message.contains('email already registered')) {
         errorMessage = "Email sudah terdaftar.";
      } else if (e.message.contains('User already registered')) {
         errorMessage = "Email sudah terdaftar.";
      } else if (e.message.contains('Password should be at least')) {
         errorMessage = "Password terlalu pendek (minimal 6 karakter).";
      }

      Get.snackbar(
        "REGISTER GAGAL",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow; 
    } catch (error) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Terjadi kesalahan tidak terduga: ${error.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }
}