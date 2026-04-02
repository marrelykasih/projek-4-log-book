import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_015/features/logbook/log_controller.dart';

void main() {
  group('Module 3: State Management & Offline Prep (LogController)', () {
    test('TC-HW06: LogController should fail to init if Hive is offline', () {
      // Karena database memori lokal (Hive) belum dinyalakan di test ini,
      // maka LogController dipastikan akan melempar error saat dibuat.
      expect(() => LogController(), throwsA(anything));
    });
  });
}
