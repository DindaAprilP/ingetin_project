import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'text_field.dart';
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

  void lihat(){
    setState(() {
      lihatPass = !lihatPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Center(
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
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>LoginScreen()),
                  );
                },
                child: Text("Login"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black
                ),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>Register()
                    ),
                  );
                },
                child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black
                  ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              width: 300,
              height: 250,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextIsi(
                    labelText: "Username",
                    iconData: Icons.person,
                  ),
                  SizedBox(height: 20),
                  TextIsi(
                    labelText: "E-mail",
                    iconData: Icons.email,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: lihatPass,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: lihat,
                        icon: Icon(
                          lihatPass ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
              final box = GetStorage();
                box.write('E-mail', emailController.text);
                Get.to(()=>LoginScreen()); // GANTI KE HALAMAN BERANDA
                Get.snackbar(
                  "REGISTER",
                  "Berhasil Daftar",
                  snackPosition : SnackPosition.TOP,
                );
              },
              child: Text("Register"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black
              ),
            ),
          ],
        ),
      )
    );
  }
}