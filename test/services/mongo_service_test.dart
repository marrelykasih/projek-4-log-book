import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_015/services/mongo_service.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';

void main() {
  group('Module 4: Cloud Database (MongoService)', () {
    late MongoService mongoService;

    setUp(() {
      mongoService = MongoService();
    });

    test('TC-HW07: getLogs should return empty list [] if disconnected',
        () async {
      var actual = await mongoService.getLogs('teamA');
      var expected = [];
      expect(actual, expected);
    });

    test('TC-HW08: connect should throw Exception if MONGODB_URI missing',
        () async {
      expect(
          () async => await mongoService.connect(), throwsA(isA<Exception>()));
    });

    test('TC-HW09: updateLog should throw Exception if LogModel ID is null',
        () async {
      final dummyLog = LogModel(
        id: null,
        title: 'Test',
        description: 'Test',
        date: '2026-04-02',
        authorId: 'user1',
        teamId: 'team1',
        category: 'Bug',
        isPublic: false,
      );
      expect(() async => await mongoService.updateLog(dummyLog),
          throwsA(isA<Exception>()));
    });
  });
}
