import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive Flutter
// Pastikan path import model ini sesuai dengan struktur folder kamu ya!
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/features/auth/login_view.dart';
import 'package:logbook_app_015/features/onboarding/onboarding_view.dart';

void main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV
  await dotenv.load(fileName: ".env");

  // --- INISIALISASI HIVE ---
  await Hive.initFlutter();
  Hive.registerAdapter(
      LogModelAdapter()); // Mendaftarkan adapter yang tadi dibuat otomatis
  await Hive.openBox<LogModel>(
      'offline_logs'); // Membuka "kotak" penyimpanan lokal

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook App 015',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menggunakan warna indigo sesuai instruksi modul
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Task 1: Halaman utama dimulai dari OnboardingView
      home: const OnboardingView(),
    );
  }
}
