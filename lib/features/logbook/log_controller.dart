import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final String username;

  // Notifier untuk menampung SEMUA data asli dari Cloud
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Notifier untuk menampilkan data di layar (bisa berubah saat di-search)
  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  LogController({required this.username});

  // 1. READ: Mengambil data dari MongoDB Atlas (Cloud)
  Future<void> loadFromDisk() async {
    try {
      // Panggil supir (MongoService) untuk ambil data di awan
      final cloudData = await MongoService().getLogs();
      logsNotifier.value = cloudData;
      filteredLogs.value =
          cloudData; // Tampilkan semua data saat pertama kali load
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal memuat data dari Cloud - $e",
          level: 1);
    }
  }

  // 2. CREATE: Menambah catatan baru ke Cloud
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(), // Bikin ID baru bawaan MongoDB
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toIso8601String(),
    );

    try {
      // Tunggu sampai data sukses dikirim ke Cloud
      await MongoService().insertLog(newLog);

      // Kalau sukses di Cloud, baru munculin di layar HP
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;
      searchLog(''); // Refresh tampilan biar data baru muncul

      await LogHelper.writeLog("SUCCESS: Tambah data ke Cloud berhasil",
          source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal nambah data - $e", level: 1);
    }
  }

  // 3. UPDATE: Memperbarui catatan di Cloud
  Future<void> updateLog(
      int index, String newTitle, String newDesc, String newCategory) async {
    // Karena kita pakai fitur search, kita harus cari posisi data yang benar
    final targetLog = filteredLogs.value[index];
    final realIndex =
        logsNotifier.value.indexWhere((log) => log.id == targetLog.id);

    if (realIndex == -1) return;

    final updatedLog = LogModel(
      id: targetLog.id, // ID harus tetap sama agar MongoDB nggak bingung
      title: newTitle,
      description: newDesc,
      category: newCategory,
      date: DateTime.now().toIso8601String(), // Catat waktu perubahan
    );

    try {
      await MongoService().updateLog(updatedLog);

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs[realIndex] = updatedLog;
      logsNotifier.value = currentLogs;
      searchLog(''); // Refresh UI
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal update data - $e", level: 1);
    }
  }

  // 4. DELETE: Menghapus catatan dari Cloud
  Future<void> removeLog(int index) async {
    final targetLog = filteredLogs.value[index];
    final realIndex =
        logsNotifier.value.indexWhere((log) => log.id == targetLog.id);

    if (realIndex == -1) return;

    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(targetLog.id!);
      }

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.removeAt(realIndex);
      logsNotifier.value = currentLogs;
      searchLog(''); // Refresh UI
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal hapus data - $e", level: 1);
    }
  }

  // 5. FITUR SEARCH: Mencari berdasarkan judul, isi, atau kategori
  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value.where((log) {
        return log.title.toLowerCase().contains(query.toLowerCase()) ||
            log.description.toLowerCase().contains(query.toLowerCase()) ||
            log.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
}
