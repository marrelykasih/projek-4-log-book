import 'package:flutter/material.dart';
import 'package:logbook_app_015/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  void _nextStep() {
    setState(() {
      if (step < 3) {
        step++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GAMBAR
              Expanded(
                child: Image.asset(
                  'assets/intro$step.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        "$step",
                        style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // TANTANGAN 1: Indikator Halaman (Titik-titik)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: step == (index + 1) ? 20 : 10, // Kalau aktif lebih lebar
                    height: 10,
                    decoration: BoxDecoration(
                      color: step == (index + 1) ? Colors.indigo : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Teks Deskripsi
              Text(
                step == 1 ? "Selamat Datang" : 
                step == 2 ? "Fitur Canggih" : "Mulai Sekarang",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Aplikasi Logbook Digital Praktikum Mobile.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Tombol
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: Text(step < 3 ? "Lanjut" : "Mulai Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}