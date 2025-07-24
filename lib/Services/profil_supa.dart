import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/models/profil_models.dart';

class ProfileService {
  final SupabaseClient _supabaseClient;
  final ImagePicker? _imagePicker;

  ProfileService(this._supabaseClient, [this._imagePicker]);
  Future<ProfilPengguna?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profil_pengguna')
          .select()
          .eq('id', userId)
          .single();

      return ProfilPengguna.fromMap(response); 
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { 
        return null;
      }
      throw Exception('Gagal mengambil profil: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  Future<void> updateProfile(ProfilPengguna profil) async {
    try {
      await _supabaseClient.from('profil_pengguna').upsert(profil.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui profil: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    try {
        await _supabaseClient.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mengubah email: ${e.message}');
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mengubah kata sandi: ${e.message}');
    }
  }

  Future<String?> pickAndUploadAvatar(String userId) async {
    if (_imagePicker == null) {
      throw Exception('ImagePicker service not provided.');
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, 
      maxHeight: 600,
    );

    if (image == null) {
      return null;
    }

    try {
      final Uint8List bytes = await image.readAsBytes();
      final fileExtension = image.path.split('.').last.toLowerCase();
      final fileName = '$userId/avatar.$fileExtension';
      await _supabaseClient.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      return _supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    } on StorageException catch (e) {
      throw Exception('Gagal mengunggah avatar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

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