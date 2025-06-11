import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ingetin/awal.dart';
import 'package:ingetin/register.dart';
import 'text_field.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
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
                  MaterialPageRoute(builder: (context)=> LoginScreen()),
                  );
                },
                child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black
                  ),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> Register()),
                  );
                },
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black
                )
                )
              ],
            ),
            SizedBox(height: 15),
            Container(
              width: 300,
              height: 200,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
                final box = GetStorage();
                box.write('username', usernameController.text);
                Get.to(()=> LoginScreen()); //GANTI KE HALAMAN BERANDA KOSONG 
                Get.snackbar(
                  "LOGIN",
                  "Berhasil Masuk",
                  snackPosition: SnackPosition.TOP,
                );
              },
              child: Text('Login'),
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