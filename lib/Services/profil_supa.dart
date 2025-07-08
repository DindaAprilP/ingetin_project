import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/models/profil_models.dart';

class ProfileService {
  final SupabaseClient _supabaseClient;
  // Jadikan ImagePicker opsional dan nullable (bisa bernilai null)
  final ImagePicker? _imagePicker;

  // Gunakan kurung siku [] untuk menandakan parameter opsional
  ProfileService(this._supabaseClient, [this._imagePicker]);

  /// Mengambil data profil dari tabel 'profil_pengguna'.
  Future<ProfilPengguna?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profil_pengguna') // Pastikan nama tabel ini benar
          .select()
          .eq('id', userId)
          .single();

      return ProfilPengguna.fromMap(response); // Pastikan method ini ada di model
    } on PostgrestException catch (e) {
      // Kondisi ini normal jika pengguna baru belum punya profil
      if (e.code == 'PGRST116') { // Kode spesifik untuk 'zero rows'
        return null;
      }
      // Untuk error lain, kita lempar lagi
      throw Exception('Gagal mengambil profil: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  /// Memperbarui atau membuat profil pengguna (upsert).
  Future<void> updateProfile(ProfilPengguna profil) async {
    try {
      await _supabaseClient.from('profil_pengguna').upsert(profil.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui profil: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  /// Mengubah email pengguna di Supabase Auth.
  Future<void> updateUserEmail(String newEmail) async {
    try {
        await _supabaseClient.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mengubah email: ${e.message}');
    }
  }

  /// Mengubah kata sandi pengguna di Supabase Auth.
  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mengubah kata sandi: ${e.message}');
    }
  }

  /// Memilih gambar dari galeri dan mengunggahnya sebagai avatar.
  Future<String?> pickAndUploadAvatar(String userId) async {
    // Tambahkan pengecekan untuk memastikan _imagePicker tersedia
    if (_imagePicker == null) {
      throw Exception('ImagePicker service not provided.');
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Ukuran wajar untuk avatar
      maxHeight: 600,
    );

    if (image == null) {
      return null;
    }

    try {
      final Uint8List bytes = await image.readAsBytes();
      final fileExtension = image.path.split('.').last.toLowerCase();
      final fileName = '$userId/avatar.$fileExtension';

      // Unggah file ke Supabase Storage
      await _supabaseClient.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Ambil URL publik dari file yang baru diunggah
      return _supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    } on StorageException catch (e) {
      throw Exception('Gagal mengunggah avatar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  /// Melakukan logout pengguna.
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout gagal: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat logout: ${e.toString()}');
    }
  }
}