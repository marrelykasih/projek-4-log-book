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

  // 1. LOAD DATA & SINKRONISASI OFFLINE KE ONLINE
  Future<void> loadLogs(String teamId) async {
    logsNotifier.value =
        _myBox.values.toList(); // Tampilkan data HP dulu biar cepat

    try {
      // Intip dulu data yang ada di awan sekarang
      final cloudData = await MongoService().getLogs(teamId);
      final cloudIds = cloudData.map((e) => e.id).toSet();

      // --- PROSES SINKRONISASI ---
      // Cek satu-satu catatan di HP. Kalau ada yang belum masuk ke awan, terbangin sekarang!
      for (var localLog in _myBox.values) {
        if (!cloudIds.contains(localLog.id)) {
          await MongoService().insertLog(localLog);
        }
      }

      // Tarik ulang data awan yang udah komplit sama kiriman barusan
      final finalCloudData = await MongoService().getLogs(teamId);

      // Bersihkan memori HP, ganti dengan data awan yang paling update
      await _myBox.clear();
      await _myBox.addAll(finalCloudData);
      logsNotifier.value = finalCloudData;

      await LogHelper.writeLog("SYNC: Data berhasil disinkronkan dengan Atlas",
          level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal",
          level: 1);
    }
  }

  // 2. ADD DATA
  Future<void> addLog(String title, String desc, String category, bool isPublic,
      String authorId, String teamId) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
      category: category,
      isPublic: isPublic,
    );

    // Simpan di HP dulu biar aman
    await _myBox.add(newLog);
    logsNotifier.value = _myBox.values.toList();

    try {
      // Langsung coba lempar ke awan
      await MongoService().insertLog(newLog);
    } catch (e) {
      await LogHelper.writeLog(
          "WARNING: Data tersimpan lokal, akan sinkron saat online",
          level: 1);
    }
  }

  // 3. UPDATE DATA
  Future<void> updateLog(int index, String title, String desc, String category,
      bool isPublic, String authorId, String teamId, String existingId) async {
    final updatedLog = LogModel(
      id: existingId,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
      category: category,
      isPublic: isPublic,
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
