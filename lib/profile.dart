import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/models/profil_models.dart';
import 'package:ingetin_project/supabase/profil_supa.dart'; 

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Inisialisasi service di sini
  late final ProfileService _profileService;
  final _usernameController = TextEditingController();

  String? _avatarUrl;
  String? _email;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi service dengan SupabaseClient dan ImagePicker
    _profileService = ProfileService(Supabase.instance.client, ImagePicker());
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('Anda belum login.', Colors.red);
        if (mounted) Navigator.pop(context);
        return;
      }

      _email = user.email;
      // Gunakan service untuk mengambil profil
      final profil = await _profileService.fetchUserProfile(user.id);

      if (profil != null) {
        _usernameController.text = profil.namaPengguna;
        _avatarUrl = profil.urlAvatar;
      } else {
        // Jika profil belum ada di database, gunakan email sebagai default username
        _usernameController.text = _email?.split('@').first ?? 'Pengguna Baru';
        _avatarUrl = null; // Pastikan avatar direset jika profil baru
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil profil: ${e.toString()}', Colors.red);
      _usernameController.text = _email?.split('@').first ?? 'Pengguna Baru'; // Fallback
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('Anda belum login.', Colors.red);
        return;
      }

      final newUsername = _usernameController.text.trim();
      if (newUsername.isEmpty) {
        _showSnackBar('Nama pengguna tidak boleh kosong.', Colors.red);
        setState(() => _isUpdating = false);
        return;
      }

      // Buat objek ProfilPengguna dan gunakan service untuk memperbarui
      final profilToUpdate = ProfilPengguna(
        id: user.id,
        namaPengguna: newUsername,
        urlAvatar: _avatarUrl,
      );
      await _profileService.updateProfile(profilToUpdate);

      _showSnackBar('Profil berhasil diperbarui!', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal memperbarui profil: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showSnackBar('Anda harus login untuk mengunggah avatar.', Colors.red);
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      // Gunakan service untuk memilih dan mengunggah avatar
      final publicUrl = await _profileService.pickAndUploadAvatar(user.id);

      if (publicUrl != null) {
        setState(() {
          _avatarUrl = publicUrl;
        });
        // Perbarui profil setelah avatar diunggah
        await _updateProfile();
        _showSnackBar('Avatar berhasil diunggah!', Colors.green);
      } else {
        _showSnackBar('Tidak ada gambar yang dipilih.', Colors.blueGrey);
      }
    } catch (e) {
      print('DEBUG: Error in _pickAndUploadAvatar: $e'); // Untuk debugging
      _showSnackBar('Terjadi kesalahan saat mengunggah avatar: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _profileService.signOut(); // Gunakan service untuk logout
      if (mounted) {
        _showSnackBar('Berhasil logout!', Colors.blue);
        // Arahkan ke halaman login atau halaman utama
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Placeholder()), // Ganti dengan halaman login/home Anda
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat logout: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fieldWidth = screenWidth > 600 ? 400 : screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.purple[100],
                              backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                              child: _avatarUrl == null || _avatarUrl!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                            ),
                            if (_isUploadingAvatar)
                              const Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black,
                                child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nama Pengguna', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alamat Email', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: TextEditingController(text: _email ?? ''),
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kata Sandi', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              obscureText: true,
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: '********',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: ElevatedButton(
                          onPressed: _isUpdating ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          ),
                          child: _isUpdating
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  'Perbarui Profil',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}