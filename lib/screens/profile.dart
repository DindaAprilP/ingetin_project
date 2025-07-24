import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingetin_project/screens/awal.dart';
import 'package:ingetin_project/screens/update_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ingetin_project/models/profil_models.dart';
import 'package:ingetin_project/Services/profil_supa.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final ProfileService _profileService;
  ProfilPengguna? _profil;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(Supabase.instance.client, ImagePicker());
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('Anda belum login.', Colors.red);
        if (mounted) Navigator.pop(context);
        return;
      }

      _email = user.email;
      final profilData = await _profileService.fetchUserProfile(user.id);
      setState(() {
        _profil = profilData ??
            ProfilPengguna(
              id: user.id,
              namaPengguna: _email?.split('@').first ?? 'Pengguna Baru',
              urlAvatar: null,
            );
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil profil: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _profileService.signOut();
      if (mounted) {
        _showSnackBar('Berhasil logout!', Colors.blue);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => splashAwal()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat logout: ${e.toString()}', Colors.red);
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
        title: const Text('Profil', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchUserProfile,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: _profil?.urlAvatar != null && _profil!.urlAvatar!.isNotEmpty
                    ? NetworkImage(_profil!.urlAvatar!)
                    : null,
                child: _profil?.urlAvatar == null || _profil!.urlAvatar!.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _profil?.namaPengguna ?? 'Pengguna',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                _email ?? 'Tidak ada email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigasi ke halaman UpdateProfile dan refresh setelah kembali
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateProfile()),
                ).then((_) => _fetchUserProfile()); // Refresh data saat kembali
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _signOut,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}