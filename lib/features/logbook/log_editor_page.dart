import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  // Variabel baru buat Fitur Kategori & Public/Private
  String _selectedCategory = 'Pribadi';
  bool _isPublic = true;
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController =
        TextEditingController(text: widget.log?.description ?? '');

    // Kalau lagi edit catatan lama, ambil data lama
    if (widget.log != null) {
      _selectedCategory = widget.log!.category;
      _isPublic = widget.log!.isPublic;
    }

    // Listener agar Pratinjau terupdate otomatis
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _selectedCategory, // Kirim kategori
        _isPublic, // Kirim status public
        widget.currentUser['uid'],
        widget.currentUser['teamId'],
      );
    } else {
      widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
        _selectedCategory, // Kirim kategori
        _isPublic, // Kirim status public
        widget.log!.authorId,
        widget.log!.teamId,
        widget.log!.id!,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: AREA NGETIK (EDITOR) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 10),

                  // --- UI FITUR KATEGORI ---
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((String cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedCategory = newValue!),
                    decoration: const InputDecoration(
                        labelText: 'Kategori', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),

                  // --- UI FITUR PUBLIC/PRIVATE ---
                  SwitchListTile(
                    title: const Text("Bagikan ke Tim (Public)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_isPublic
                        ? "Teman setim bisa melihat catatan ini"
                        : "Hanya Anda yang bisa melihat catatan ini"),
                    value: _isPublic,
                    activeColor: Colors.blue.shade800,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const Divider(),

                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan dengan format Markdown...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB 2: AREA LIHAT HASIL (PRATINJAU) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MarkdownBody(data: _descController.text),
            ),
          ],
        ),
      ),
    );
  }
}
