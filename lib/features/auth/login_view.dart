import 'package:flutter/material.dart';
import 'dart:async'; // Wajib untuk Timer
import 'package:logbook_app_015/features/auth/login_controller.dart';
import 'package:logbook_app_015/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true;
  int _secondsLeft = 0;

  void _handleLogin() {
    String user = _userController.text.toLowerCase().trim();
    String pass = _passController.text.trim();

    // Security Logic: Validasi field tidak boleh kosong
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
        ),
      );
      return;
    }

    // Siapkan wadah untuk data user
    Map<String, dynamic>? loggedInUser;

    // --- DAFTAR 3 AKUN PASTI BUAT NGETES ---
    if (user == 'ketua' && pass == '123') {
      loggedInUser = {
        'uid': 'user_001',
        'username': 'Bapak Ketua',
        'role': 'Ketua',
        'teamId': 'Tim_A',
      };
    } else if (user == 'anggota1' && pass == '123') {
      loggedInUser = {
        'uid': 'user_002',
        'username': 'Anggota Satu',
        'role': 'Anggota',
        'teamId': 'Tim_A',
      };
    } else if (user == 'anggota2' && pass == '123') {
      loggedInUser = {
        'uid': 'user_003',
        'username': 'Anggota Dua',
        'role': 'Anggota',
        'teamId': 'Tim_A',
      };
    }

    // Jika ketikan cocok dengan salah satu akun di atas
    if (loggedInUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(currentUser: loggedInUser!),
        ),
      );
    } else {
      // Jika akun tidak ada, jalankan sistem keamanan dari LoginController
      _controller.login(user, pass); // Memicu hitungan gagal

      if (_controller.isLocked) _startLockdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.isLocked
                ? "Terlalu banyak percobaan! Tunggu 10 detik."
                : "Login Gagal! Akun tidak ditemukan atau password salah.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startLockdown() {
    setState(() => _secondsLeft = 10);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _controller.unlock());
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Security")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              // Tombol menjadi disabled (null) jika sedang locked
              onPressed: (_secondsLeft > 0) ? null : _handleLogin,
              child: Text(
                _secondsLeft > 0 ? "Terkunci ($_secondsLeft s)" : "Masuk",
              ),
            ),
            const SizedBox(height: 30),
            // Catatan kecil di layar biar kamu nggak lupa akunnya
            const Text(
              "Akun Testing:\n1. ketua (pass: 123)\n2. anggota1 (pass: 123)\n3. anggota2 (pass: 123)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
