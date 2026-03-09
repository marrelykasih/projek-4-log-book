import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int value = 0;
  List<String> history = [];

  // Load data
  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getInt('counter_$username') ?? 0;
    history = prefs.getStringList('history_$username') ?? [];
  }

  // LOGIKA TAMBAH (Increment)
  Future<void> increment(String username) async {
    final prefs = await SharedPreferences.getInstance();
    value++;
    _saveToStorage(username, "menambah");
  }

  // LOGIKA KURANG (Decrement) - Baru!
  Future<void> decrement(String username) async {
    final prefs = await SharedPreferences.getInstance();
    value--;
    _saveToStorage(username, "mengurangi");
  }

  // Fungsi Simpan (Biar gak nulis ulang kodingan)
  Future<void> _saveToStorage(String username, String action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_$username', value);

    String log =
        "User $username $action angka pada ${DateTime.now().hour}:${DateTime.now().minute}";
    history.insert(0, log);
    await prefs.setStringList('history_$username', history);
  }
}
