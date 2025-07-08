import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ingetin_project/widgets/navbottom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register.dart';
import '../models/text_field.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool lihatPass = true;
  bool isLoading = false;

  void lihat(){
    setState(() {
      lihatPass = !lihatPass;
    });
  }

  Future<void> loginWithSupabase() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "LOGIN GAGAL",
        "Email dan password tidak boleh kosong",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "LOGIN GAGAL",
        "Format email tidak valid",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        try {
          final profileResponse = await supabase
              .from('profil_pengguna')
              .select('nama_pengguna, url_avatar')
              .eq('id', response.user!.id)
              .single();

          final box = GetStorage();
          box.write('user_id', response.user!.id);
          box.write('email', response.user!.email);
          box.write('username', profileResponse['nama_pengguna'] ?? '');
          box.write('avatar_url', profileResponse['url_avatar'] ?? '');

          Get.offAll(() => const bottomNavigationBar());
          Get.snackbar(
            "LOGIN BERHASIL",
            "Selamat datang, ${profileResponse['nama_pengguna'] ?? 'User'}!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (profileError) {
          final box = GetStorage();
          box.write('user_id', response.user!.id);
          box.write('email', response.user!.email);
          box.write('username', '');
          box.write('avatar_url', '');

          Get.offAll(() => const bottomNavigationBar());
          Get.snackbar(
            "LOGIN BERHASIL",
            "Selamat datang!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (error) {
      String errorMessage = "Terjadi kesalahan saat login";
      
      // Handle specific errors
      if (error.toString().contains('Invalid login credentials')) {
        errorMessage = "Email atau password salah";
      } else if (error.toString().contains('Email not confirmed')) {
        errorMessage = "Email belum dikonfirmasi";
      } else if (error.toString().contains('Too many requests')) {
        errorMessage = "Terlalu banyak percobaan login. Coba lagi nanti";
      } else if (error.toString().contains('Invalid email')) {
        errorMessage = "Format email tidak valid";
      }
      
      Get.snackbar(
        "LOGIN GAGAL",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/login.png",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const Register());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: 300,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextIsi(
                      controller: emailController,
                      labelText: "E-mail",
                      iconData: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextIsi(
                      controller: passwordController,
                      labelText: "Password",
                      iconData: Icons.lock,
                      obscureText: lihatPass,
                      suffixIcon: lihatPass ? Icons.visibility_off : Icons.visibility,
                      onSuffixIconPressed: lihat,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginWithSupabase,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                  child: isLoading 
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Loading...'),
                        ],
                      )
                    : Text('Login'),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}