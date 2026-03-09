import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/services/mongo_service.dart';
import 'package:logbook_app_015/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Membuka koneksi ke memori lokal Hive
  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  // 1. LOAD DATA: Ambil lokal dulu, baru tarik dari Cloud
  Future<void> loadLogs(String teamId) async {
    logsNotifier.value = _myBox.values.toList(); // Instan dari HP

    try {
      final cloudData = await MongoService().getLogs(teamId);
      await _myBox.clear();
      await _myBox.addAll(cloudData); // Sinkronkan HP dengan Cloud
      logsNotifier.value = cloudData;
      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas",
          level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal",
          level: 1);
    }
  }

  // 2. ADD DATA: Simpan lokal, lalu lempar ke Cloud
  Future<void> addLog(String title, String desc, String category,
      String authorId, String teamId) async {
    final newLog = LogModel(
      id: ObjectId().oid, // String ID untuk Hive
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
    );

    await _myBox.add(newLog); // Simpan Instan ke Hive
    logsNotifier.value = _myBox.values.toList();

    try {
      await MongoService().insertLog(newLog); // Background upload
    } catch (e) {
      await LogHelper.writeLog(
          "WARNING: Data tersimpan lokal, akan sinkron saat online",
          level: 1);
    }
  }

  // 3. UPDATE DATA
  Future<void> updateLog(int index, String title, String desc, String category,
      String authorId, String teamId, String existingId) async {
    final updatedLog = LogModel(
      id: existingId,
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
    );

    await _myBox.putAt(index, updatedLog);
    logsNotifier.value = _myBox.values.toList();

    try {
      await MongoService().updateLog(updatedLog);
    } catch (e) {}
  }

  // 4. DELETE DATA
  Future<void> removeLog(int index) async {
    final targetId = logsNotifier.value[index].id;
    await _myBox.deleteAt(index);
    logsNotifier.value = _myBox.values.toList();

    if (targetId != null) {
      try {
        await MongoService().deleteLog(targetId);
      } catch (e) {}
    }
  }
}
