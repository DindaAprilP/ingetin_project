import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ingetin_project/widgets/navbottom.dart';
import 'package:ingetin_project/widgets/custom_text_field.dart';
import 'package:ingetin_project/services/auth_services.dart';
import 'package:ingetin_project/screens/login.dart';

class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool lihatPass = true;
  bool isLoading = false;

  final AuthService _authService = AuthService(); 

  void _toggleVisibility() { 
    setState(() {
      lihatPass = !lihatPass;
    });
  }

  Future<void> _handleRegister() async { 
    setState(() {
      isLoading = true;
    });

    try {
      await _authService.registerUser(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAll(() => bottomNavigationBar());
    } catch (e) {
      print("Register failed: $e"); 
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
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const LoginScreen()); 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                      controller: usernameController,
                      labelText: "Username",
                      iconData: Icons.person,
                    ),
                    const SizedBox(height: 20),
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
                      onSuffixIconPressed: _toggleVisibility, 
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister, 
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                  child: isLoading
                      ? const Row(
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
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
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