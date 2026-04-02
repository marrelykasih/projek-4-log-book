import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_015/features/auth/login_controller.dart';

void main() {
  group('Module 2: Authentication (LoginController)', () {
    late LoginController loginController;

    setUp(() {
      loginController = LoginController();
    });

    test('TC-HW01: login should return true for valid credentials', () {
      var actual = loginController.login('admin', '123');
      var expected = true;
      expect(actual, expected);
    });

    test('TC-HW02: login should return false for invalid credentials', () {
      var actual = loginController.login('admin', 'salah123');
      var expected = false;
      expect(actual, expected);
    });

    test('TC-HW03: login should lock account after 3 failed attempts', () {
      loginController.login('admin', 'salah1');
      loginController.login('admin', 'salah2');
      loginController.login('admin', 'salah3');
      var actual = loginController.isLocked;
      var expected = true;
      expect(actual, expected);
    });

    test('TC-HW04: unlock should reset lock status and wrong attempts', () {
      loginController.login('admin', 'salah1');
      loginController.login('admin', 'salah2');
      loginController.login('admin', 'salah3'); // Terkunci
      loginController.unlock();
      var actual = loginController.isLocked;
      var expected = false;
      expect(actual, expected);
    });

    test('TC-HW05: successful login should reset wrong attempts', () {
      loginController.login('admin', 'salah1'); // Salah 1x
      loginController.login('admin', '123'); // Sukses (reset ke 0)
      loginController.login('admin', 'salah2'); // Salah 1x lagi
      loginController.login('admin', 'salah3'); // Salah 2x lagi
      var actual = loginController.isLocked;
      var expected = false; // Belum terkunci karena baru salah 2x setelah reset
      expect(actual, expected);
    });
  });
}
