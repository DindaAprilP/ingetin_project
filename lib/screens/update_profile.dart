import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/services/profil_supa.dart';
import 'package:ingetin_project/models/profil_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late final ProfileService _profileService;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _avatarUrl;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(Supabase.instance.client, ImagePicker());
    _loadInitialProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('Sesi berakhir, silahkan login kembali.', Colors.red);
        if (mounted) Navigator.pop(context);
        return;
      }
      final profil = await _profileService.fetchUserProfile(user.id);
      if (profil != null) {
        _usernameController.text = profil.namaPengguna;
        _avatarUrl = profil.urlAvatar;
      }
      _emailController.text = user.email ?? '';
    } catch (e) {
      _showSnackBar('Gagal memuat profil: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSave() async {
    setState(() => _isUpdating = true);

    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final user = Supabase.instance.client.auth.currentUser!;

    if (newUsername.isEmpty || newEmail.isEmpty) {
      _showSnackBar('Nama pengguna dan email tidak boleh kosong.', Colors.red);
      setState(() => _isUpdating = false);
      return;
    }

    try {
      final profilToUpdate = ProfilPengguna(
        id: user.id,
        namaPengguna: newUsername,
        urlAvatar: _avatarUrl,
      );
      await _profileService.updateProfile(profilToUpdate);

      final isEmailChanged = newEmail != user.email;
      if (isEmailChanged) {
        await _profileService.updateUserEmail(newEmail);
        _showSnackBar(
            'Profil disimpan. Periksa email lama dan baru untuk konfirmasi.',
            Colors.blue);
      } else {
        _showSnackBar('Profil berhasil diperbarui!', Colors.green);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Gagal memperbarui: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || newPassword.length < 6) {
      _showSnackBar('Kata sandi minimal 6 karakter.', Colors.red);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackBar('Kata sandi tidak cocok.', Colors.red);
      return;
    }

    setState(() => _isUpdating = true);
    Navigator.of(context).pop(); 

    try {
      await _profileService.updateUserPassword(newPassword);
      _showSnackBar('Kata sandi berhasil diubah!', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal mengubah kata sandi: $e', Colors.red);
    } finally {
      setState(() => _isUpdating = false);
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Kata Sandi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Baru'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Konfirmasi Kata Sandi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Ubah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    setState(() => _isUploadingAvatar = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final publicUrl = await _profileService.pickAndUploadAvatar(userId);
      if (publicUrl != null) {
        setState(() => _avatarUrl = publicUrl);
        _showSnackBar('Avatar berhasil diunggah!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Gagal mengunggah avatar: $e', Colors.red);
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text('Edit Profil',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: [
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: _avatarUrl != null &&
                                  _avatarUrl!.isNotEmpty
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.black)
                              : null,
                        ),
                        if (_isUploadingAvatar)
                          const Positioned.fill(
                            child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Nama Pengguna', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Alamat Email', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isUpdating ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Simpan Perubahan',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _showPasswordDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ubah Kata Sandi',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ],
            ),
    );
  }
}