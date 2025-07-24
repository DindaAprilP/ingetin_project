import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ingetin_project/screens/awal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/ApiKey.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const Ingetin());
}

final supabase = Supabase.instance.client;

class Ingetin extends StatelessWidget {
  const Ingetin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ingetin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const splashAwal(),
    );
  }
}
