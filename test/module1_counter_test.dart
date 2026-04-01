// test/module1_counter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan alamat import ini sesuai dengan letak file CounterController kamu
import 'package:logbook_app_015/features/logbook/counter_controller.dart';

void main() {
  var actual, expected;

  group('Module 1 - CounterController (Refactored)', () {
    late CounterController controller;
    const username = "admin";

    setUp(() async {
      // (1) setup (arrange, build)
      SharedPreferences.setMockInitialValues({}); // mock storage kosong
      controller = CounterController();
      await controller.loadData(username); // load initial value
    });

    // Sesuaikan dengan TC04
    test('increment should increase value by 1', () async {
      // (2) exercise (act, operate)
      await controller.increment(username);
      actual = controller.value;
      expected = 1; // Karena awalnya 0, ditambah 1 jadi 1

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    // Sesuaikan dengan TC05
    test('decrement should decrease value by 1', () async {
      // (1) setup (arrange, build)
      await controller.increment(username); // Kita naikkan jadi 1 dulu

      // (2) exercise (act, operate)
      await controller.decrement(username);
      actual = controller.value;
      expected = 0; // 1 dikurangi 1 jadi 0

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    // Sesuaikan dengan TC07
    test('history should record increment action', () async {
      // (2) exercise (act, operate)
      await controller.increment(username);
      actual = controller.history.first.contains("menambah");
      expected = true;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    // Sesuaikan dengan TC08
    test('history should record decrement action', () async {
      // (2) exercise (act, operate)
      await controller.decrement(username);
      actual = controller.history.first.contains("mengurangi");
      expected = true;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    // Sesuaikan dengan TC09
    test('loadData should retrieve existing data from storage', () async {
      // (1) setup (arrange, build) - Kita isi datanya seolah-olah udah ada
      SharedPreferences.setMockInitialValues({
        'counter_$username': 5,
        'history_$username': ['User admin menambah angka pada 12:00']
      });
      final newController = CounterController();

      // (2) exercise (act, operate)
      await newController.loadData(username);
      actual = newController.value;
      expected = 5;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(newController.history.isNotEmpty, true);
    });

    // Sesuaikan dengan TC10
    test('loadData should handle empty storage safely', () async {
      // (1) setup (arrange, build) - Storage kosong
      SharedPreferences.setMockInitialValues({});
      final newController = CounterController();

      // (2) exercise (act, operate)
      await newController.loadData(username);
      actual = newController.value;
      expected = 0;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(newController.history.isEmpty, true);
    });
  });
}
