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
    String user = _userController.text;
    String pass = _passController.text;

    // Security Logic: Validasi field tidak boleh kosong
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
        ),
      );
      return;
    }

    if (_controller.login(user, pass)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogView(username: user)),
      );
    } else {
      if (_controller.isLocked) _startLockdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.isLocked
                ? "Terlalu banyak percobaan! Tunggu 10 detik."
                : "Login Gagal! Akun tidak ditemukan.",
          ),
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
          ],
        ),
      ),
    );
  }
}
