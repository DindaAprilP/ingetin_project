import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'login.dart';
import 'package:ingetin_project/widgets/navbottom.dart';

class splashAwal extends StatefulWidget {
  const splashAwal({super.key});

  @override
  State<splashAwal> createState() => _splashAwalState();
}

class _splashAwalState extends State<splashAwal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward(); 

    Future.delayed(const Duration(seconds: 3), () { 
      _redirect();
    });
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const bottomNavigationBar());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  "assets/splashAwal.png",
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Image.asset(
                "assets/IngetinHitam.png",
                width: 120,
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}