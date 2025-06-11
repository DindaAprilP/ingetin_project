import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login.dart';

class splashAwal extends StatefulWidget {
  const splashAwal({super.key});

  @override
  State<splashAwal> createState() => _splashAwalState();
}

class _splashAwalState extends State<splashAwal> {
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 3), (){
      Get.off (()=> LoginScreen());
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
            Container(
              width: 150,
              height: 150,
              child: Image.asset(
                "assets/splashAwal.png",
                width: 120,
                height: 120,
                ),
            ),
            SizedBox(height: 5),
            Container(
              width: 100,
              height: 150,
              child: Image.asset(
                "assets/ingetinHitam.png"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
