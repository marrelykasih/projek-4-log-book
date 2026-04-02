import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_015/services/mongo_service.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';

void main() {
  group('Test Modul 4: Cloud Database (Mongo Service)', () {
    late MongoService mongoService;

    setUp(() {
      // Setup: Buat objek MongoService sebelum tiap tes dijalankan
      mongoService = MongoService();
    });

    test('TC-HW05: getLogs should return empty list on connection error',
        () async {
      // Exercise: Panggil getLogs
      var actual = await mongoService.getLogs('teamA');

      // Verify: Pastikan mengembalikan list kosong [] saat gagal konek ke MongoDB
      expect(actual.isEmpty, true);
    });

    test('TC-HW06: connect should throw Exception if MONGODB_URI missing',
        () async {
      // Exercise & Verify: Panggil connect() tanpa .env dan pastikan melempar Exception
      expect(
          () async => await mongoService.connect(), throwsA(isA<Exception>()));
    });

    test('TC-HW07: updateLog should throw Exception if ID is null', () async {
      // Setup: Buat objek dummy LogModel dengan id kosong (null)
      final dummyLog = LogModel(
        id: null,
        title: 'Test Error',
        description: 'Testing update with null ID',
        date: '2026-04-02',
        authorId: 'user1',
        teamId: 'team1',
        category: 'Bug',
        isPublic: false,
      );

      // Exercise & Verify: Panggil updateLog() dan pastikan melempar Exception
      expect(() async => await mongoService.updateLog(dummyLog),
          throwsA(isA<Exception>()));
    });
  });
}
