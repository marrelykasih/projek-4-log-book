class LoginController {
  final Map<String, String> _users = {"admin": "123", "marrely": "015"};

  int _wrongAttempts = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  bool login(String username, String password) {
    if (_users.containsKey(username) && _users[username] == password) {
      _wrongAttempts = 0;
      return true;
    } else {
      _wrongAttempts++;
      if (_wrongAttempts >= 3) _isLocked = true; // Kunci jika salah 3x
      return false;
    }
  }

  void unlock() {
    _isLocked = false;
    _wrongAttempts = 0;
  }
}
