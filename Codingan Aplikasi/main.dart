import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bayi/UI/Splash.dart';
import 'package:bayi/database/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://jpsoscpcjegyrlpjoxtg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impwc29zY3BjamVneXJscGpveHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1OTc2MjEsImV4cCI6MjA5MDE3MzYyMX0.hsy4wKqT8KQuuCn5G6u7mBl921jfPOOu0IM6SR9ozco',
  );
  // await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}