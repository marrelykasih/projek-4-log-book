import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib untuk Tugas 3: Timestamp
import 'models/log_model.dart';
import 'log_controller.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => LogViewState();
}

class LogViewState extends State<LogView> {
  late final LogController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception("Timeout"),
          );
      await _controller.loadFromDisk();
    } catch (e) {
      await LogHelper.writeLog("UI: Error - $e",
          source: "log_view.dart", level: 1);
      if (mounted) {
        // TUGAS 1: CONNECTION GUARD (Offline Mode Warning)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        "Offline Mode Warning: Gagal terhubung ke Cloud. Periksa koneksi internetmu.")),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // TUGAS 3: TIMESTAMP FORMATTING
  String _formatTimestamp(String dateString) {
    if (dateString.isEmpty) return "";
    try {
      DateTime logDate = DateTime.parse(dateString).toLocal();
      Duration diff = DateTime.now().difference(logDate);

      if (diff.inSeconds < 60) return "Baru saja";
      if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
      if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
      if (diff.inDays < 7) return "${diff.inDays} hari yang lalu";

      // Jika lebih dari seminggu, tampilkan tanggal format lokal (Contoh: 25 Jan 2026)
      return DateFormat('dd MMM yyyy, HH:mm').format(logDate);
    } catch (e) {
      return dateString;
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'Pribadi';
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade100;
      case 'Urgent':
        return Colors.indigo.shade100;
      case 'Pribadi':
      default:
        return Colors.lightBlue.shade50;
    }
  }

  void _showAddLogDialog() {
    _selectedCategory = 'Pribadi';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Tambah Catatan",
              style: TextStyle(
                  color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    hintText: "Judul Catatan",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade800))),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                    hintText: "Isi Deskripsi",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade800))),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((String cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (newValue) =>
                    setStateDialog(() => _selectedCategory = newValue!),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade800, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white),
              onPressed: () {
                _controller.addLog(_titleController.text,
                    _contentController.text, _selectedCategory);
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      }),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Catatan",
              style: TextStyle(
                  color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.shade800)))),
              TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.shade800)))),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((String cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (newValue) =>
                    setStateDialog(() => _selectedCategory = newValue!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade800, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white),
              onPressed: () {
                _controller.updateLog(index, _titleController.text,
                    _contentController.text, _selectedCategory);
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Logbook Cloud",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue.shade200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.blue.shade800, width: 2)),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {
                if (_isLoading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text("Menghubungkan ke MongoDB Atlas...",
                            style: TextStyle(color: Colors.blue.shade800)),
                      ],
                    ),
                  );
                }

                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off,
                            size: 80, color: Colors.blue.shade300),
                        const SizedBox(height: 16),
                        Text("Belum ada catatan di Cloud.",
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                // TUGAS 2: PULL-TO-REFRESH WIDGET
                return RefreshIndicator(
                  onRefresh: _initDatabase,
                  color: Colors.blue.shade800,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Wajib ada agar layar selalu bisa ditarik
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];
                      return Dismissible(
                        key: Key(log.date),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_sweep,
                              color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) =>
                            _controller.removeLog(index),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: _getCategoryColor(log.category),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                                backgroundColor: Colors.white54,
                                child: Icon(Icons.cloud_done,
                                    color: Colors.blue.shade800)),
                            title: Text(log.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.description,
                                      style: TextStyle(
                                          color: Colors.blue.shade800)),
                                  const SizedBox(height: 6),
                                  // TAMPILAN TUGAS 3: WAKTU
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade700),
                                      const SizedBox(width: 4),
                                      Text(_formatTimestamp(log.date),
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.edit_note,
                                    color: Colors.blue.shade700, size: 28),
                                onPressed: () =>
                                    _showEditLogDialog(index, log)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
