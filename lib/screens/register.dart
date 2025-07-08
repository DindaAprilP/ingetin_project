import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/navbottom.dart';
import '../models/text_field.dart';
import 'package:get/get.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool lihatPass = true;
  bool isLoading = false;

  void lihat(){
    setState(() {
      lihatPass = !lihatPass;
    });
  }

  Future<void> registerWithSupabase() async {
    // Validasi input kosong
    if (usernameController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty || 
        passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Semua field harus diisi",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (usernameController.text.trim().length > 50) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Username maksimal 50 karakter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text.trim())) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Username hanya boleh berisi huruf, angka, dan underscore",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi password minimal 6 karakter
    if (passwordController.text.length < 6) {
      Get.snackbar(
        "REGISTER GAGAL",
        "Password minimal 6 karakter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "REGISTER GAGAL",
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
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'nama_pengguna': usernameController.text.trim(), // Sesuai dengan database
        },
      );

      if (response.user != null) {
        final box = GetStorage();
        box.write('user_id', response.user!.id);
        box.write('email', response.user!.email);
        box.write('username', usernameController.text.trim());
        
        Get.offAll(() => bottomNavigationBar());
        Get.snackbar(
          "REGISTER BERHASIL",
          "Akun berhasil dibuat!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      String errorMessage = "Terjadi kesalahan saat mendaftar";
      
      // Handle specific errors
      if (error.toString().contains('duplicate key value violates unique constraint')) {
        errorMessage = "Username sudah digunakan";
      } else if (error.toString().contains('invalid email')) {
        errorMessage = "Format email tidak valid";
      } else if (error.toString().contains('email already registered') || 
                error.toString().contains('User already registered')) {
        errorMessage = "Email sudah terdaftar";
      } else if (error.toString().contains('Password should be at least')) {
        errorMessage = "Password terlalu pendek";
      }
      
      Get.snackbar(
        "REGISTER GAGAL",
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Login (bisa diklik)
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginScreen());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              Container(
                width: 300,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextIsi(
                      controller: usernameController,
                      labelText: "Username",
                      iconData: Icons.person,
                    ),
                    SizedBox(height: 20),
                    TextIsi(
                      controller: emailController,
                      labelText: "E-mail",
                      iconData: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    TextIsi(
                      controller: passwordController,
                      labelText: "Password",
                      iconData: Icons.lock,
                      obscureText: lihatPass,
                      suffixIcon: lihatPass ? Icons.visibility_off : Icons.visibility,
                      onSuffixIconPressed: lihat,
                    )
                  ],
                )
              ),
              
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerWithSupabase,
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
                    : Text('Register'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}