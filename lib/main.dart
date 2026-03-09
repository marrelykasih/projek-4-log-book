import 'package:flutter/material.dart';
// Alamat import sudah diarahkan ke folder onboarding yang baru
import 'package:logbook_app_015/features/onboarding/onboarding_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  // Load ENV
  await dotenv.load(fileName: ".env");
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
