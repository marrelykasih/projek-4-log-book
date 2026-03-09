import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_015/features/logbook/models/log_model.dart';
import 'package:logbook_app_015/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  // Untuk sementara kita pakai String biasa dulu buat simulasi identitas
  final String currentUserId;
  final String currentTeamId;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUserId,
    required this.currentTeamId,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  // Tambahan variabel untuk kategori yang tadi kita selamatkan
  String _selectedCategory = 'Pribadi';
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController =
        TextEditingController(text: widget.log?.description ?? '');
    if (widget.log != null) {
      _selectedCategory = widget.log!.category;
    }

    // Listener agar Pratinjau terupdate otomatis saat kita ngetik
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      widget.controller.addLog(
          _titleController.text,
          _descController.text,
          _selectedCategory,
          widget.currentUserId,
          widget.currentTeamId // Kirim identitas pembuat
          );
    } else {
      widget.controller.updateLog(
          widget.index!,
          _titleController.text,
          _descController.text,
          _selectedCategory,
          widget.log!.authorId,
          widget.log!.teamId,
          widget.log!.id!);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Bersihkan memori HP saat halaman ditutup
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DefaultTabController buat bikin 2 Tab (Editor & Pratinjau)
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
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((String cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedCategory = newValue!),
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null, // Biar bisa ngetik panjang ke bawah
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
              // Widget MarkdownBody ini yang bakal nyulap kode jadi teks rapi!
              child: MarkdownBody(data: _descController.text),
            ),
          ],
        ),
      ),
    );
  }
}
