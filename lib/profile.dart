import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/models/profil_models.dart';
import 'dart:typed_data';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;
  final _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _avatarUrl;
  String? _email;
  bool _isLoading = true; 
  bool _isUpdating = false; 
  bool _isUploadingAvatar = false; 

  @override
  void initState() {
    super.initState();
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
      final user = supabase.auth.currentUser;
      if (user == null) {
        _showSnackBar('Anda belum login.', Colors.red);
        if (mounted) Navigator.pop(context); 
        return;
      }

      _email = user.email; 

      final response = await supabase
          .from('profil_pengguna')
          .select()
          .eq('id', user.id)
          .single();

      final profil = ProfilPengguna.fromMap(response);
      _usernameController.text = profil.namaPengguna;
      _avatarUrl = profil.urlAvatar;
    } on PostgrestException catch (e) {
      _showSnackBar('Gagal mengambil profil: ${e.message}', Colors.red);
      _usernameController.text = _email?.split('@').first ?? 'Pengguna Baru';
    } catch (e) {
      _showSnackBar('Terjadi kesalahan tak terduga: ${e.toString()}', Colors.red);
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
      final user = supabase.auth.currentUser;
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

       final profilData = {
        'id': user.id, 
        'nama_pengguna': newUsername,
        'url_avatar': _avatarUrl,
      };

      await supabase.from('profil_pengguna').upsert(profilData);

      _showSnackBar('Profil berhasil diperbarui!', Colors.green);
    } on PostgrestException catch (e) {
      _showSnackBar('Gagal memperbarui profil: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan tak terduga: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnackBar('Anda harus login untuk mengunggah avatar.', Colors.red);
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      _showSnackBar('Tidak ada gambar yang dipilih.', Colors.blueGrey);
      return;
    }

    print('Selected image path: ${image.path}');

    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final Uint8List bytes = await image.readAsBytes();

      final fileExtension = image.path.split('.').last;
      final fileName = '${user.id}/avatar.$fileExtension';

      await supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes, 
            fileOptions: const FileOptions(upsert: true), 
          );

      final String publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      setState(() {
        _avatarUrl = publicUrl; 
      });

      await _updateProfile();

      _showSnackBar('Avatar berhasil diunggah!', Colors.green);
    } on StorageException catch (e) {
      _showSnackBar('Gagal mengunggah avatar: ${e.message}', Colors.red);
    } catch (e) {
      print('DEBUG: Error in _pickAndUploadAvatar: $e');
      _showSnackBar('Terjadi kesalahan tak terduga: ${e.toString()}', Colors.red);
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
      await supabase.auth.signOut();
      if (mounted) {
        _showSnackBar('Berhasil logout!', Colors.blue);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Placeholder()), 
          (Route<dynamic> route) => false,
        );
      }
    } on AuthException catch (e) {
      _showSnackBar('Logout gagal: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan tak terduga saat logout: ${e.toString()}', Colors.red);
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
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Profil',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), 
                      ],
                    ),
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

//biar bisa push