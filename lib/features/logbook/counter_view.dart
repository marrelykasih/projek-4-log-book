import 'package:flutter/material.dart';
import 'package:logbook_app_015/features/logbook/counter_controller.dart';
import 'package:logbook_app_015/features/auth/login_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _controller.loadData(widget.username);
    setState(() {});
  }

  // ... (Fungsi _getTimeBasedGreeting dan _showLogoutDialog sama seperti sebelumnya) ...
  // Biar hemat tempat, copy paste fungsi salam dan logout dari kodingan sebelumnya ya!
  String _getTimeBasedGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Colors.indigo, // Warna AppBar
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: _showLogoutDialog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Salam
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_getTimeBasedGreeting()}, ${widget.username}!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Total Hitungan Anda:"),
            Text(
              "${_controller.value}",
              style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),

            const SizedBox(height: 30),

            // --- MODUL 1C: TOMBOL MERAH (KURANG) & HIJAU (TAMBAH) ---
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Biar jaraknya rapi
              children: [
                // Tombol Kurang (MERAH)
                ElevatedButton.icon(
                  onPressed: () async {
                    await _controller.decrement(widget.username);
                    setState(() {});
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text("Kurang"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // MERAH
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 50),
                  ),
                ),

                // Tombol Tambah (HIJAU)
                ElevatedButton.icon(
                  onPressed: () async {
                    await _controller.increment(widget.username);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // HIJAU
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 50),
                  ),
                ),
              ],
            ),
            // ---------------------------------------------------------

            const Divider(height: 40),

            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        // Ikon berubah sesuai aksi (naik/turun)
                        _controller.history[index].contains("menambah")
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: _controller.history[index].contains("menambah")
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(_controller.history[index],
                          style: const TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
