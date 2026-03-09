import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_015/features/logbook/log_controller.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/services/access_control_service.dart';
import 'package:logbook_app_015/features/logbook/log_editor_page.dart';
import 'package:logbook_app_015/services/mongo_service.dart';
import 'package:logbook_app_015/features/auth/login_view.dart'; // Wajib buat navigasi Log Out

class LogView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const LogView({
    super.key,
    this.currentUser = const {
      'uid': 'user_123',
      'username': 'Marrely',
      'role': 'Ketua',
      'teamId': 'Tim_A',
    },
  });

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception("Timeout"),
          );
      await _controller.loadLogs(widget.currentUser['teamId']);
    } catch (e) {
      await _controller.loadLogs(widget.currentUser['teamId']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                      "Offline Mode: Gagal terhubung ke Cloud. Menggunakan data memori HP."),
                ),
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

  String _formatTimestamp(String dateString) {
    if (dateString.isEmpty) return "";
    try {
      DateTime logDate = DateTime.parse(dateString).toLocal();
      Duration diff = DateTime.now().difference(logDate);

      if (diff.inSeconds < 60) return "Baru saja";
      if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
      if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
      if (diff.inDays < 7) return "${diff.inDays} hari yang lalu";

      return DateFormat('dd MMM yyyy, HH:mm').format(logDate);
    } catch (e) {
      return dateString;
    }
  }

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

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUserId: widget.currentUser['uid'],
          currentTeamId: widget.currentUser['teamId'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Logbook: ${widget.currentUser['username']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        // --- INI DIA TOMBOL LOG OUT-NYA ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text("Konfirmasi Logout",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text(
                      "Apakah Anda yakin ingin keluar dari akun ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        // Navigasi hapus memori halaman dan balik ke Login
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Ya, Keluar"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade800,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari judul atau isi catatan...",
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                final filteredLogs = currentLogs.where((log) {
                  return log.title.toLowerCase().contains(_searchQuery) ||
                      log.description.toLowerCase().contains(_searchQuery);
                }).toList();

                if (_isLoading && currentLogs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 80, color: Colors.blue.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? "Belum ada catatan tim."
                              : "Pencarian tidak ditemukan.",
                          style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _initDatabase,
                  color: Colors.blue.shade800,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final realIndex = currentLogs.indexOf(log);

                      final bool isOwner =
                          log.authorId == widget.currentUser['uid'];
                      final bool canDelete = AccessControlService.canPerform(
                          widget.currentUser['role'],
                          AccessControlService.actionDelete,
                          isOwner: isOwner);
                      final bool canEdit = AccessControlService.canPerform(
                          widget.currentUser['role'],
                          AccessControlService.actionUpdate,
                          isOwner: isOwner);

                      Widget cardContent = Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: _getCategoryColor(log.category),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: canEdit
                              ? () => _goToEditor(log: log, index: realIndex)
                              : null,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white54,
                              child: Icon(
                                  log.id != null
                                      ? Icons.cloud_done
                                      : Icons.cloud_upload_outlined,
                                  color: log.id != null
                                      ? Colors.blue.shade800
                                      : Colors.orange),
                            ),
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.blue.shade800)),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
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
                                      Text(log.category,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: canEdit
                                ? IconButton(
                                    icon: Icon(Icons.edit_note,
                                        color: Colors.blue.shade700, size: 28),
                                    onPressed: () =>
                                        _goToEditor(log: log, index: realIndex),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      );

                      if (canDelete) {
                        return Dismissible(
                          key: Key(log.id ?? log.date),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(15)),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_sweep,
                                color: Colors.white, size: 30),
                          ),
                          onDismissed: (direction) =>
                              _controller.removeLog(realIndex),
                          child: cardContent,
                        );
                      }

                      return cardContent;
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
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
