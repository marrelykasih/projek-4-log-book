import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id; // Wajib ditambahkan untuk identitas unik MongoDB
  final String title;
  final String description;
  final String category;
  final String date;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
  });

  // Mapping ke BSON agar bisa dikirim ke internet
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'title': title,
      'description': description,
      'category': category,
      'date': date,
    };
  }

  // Membongkar kembali data dari Cloud menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
      date: map['date'] ?? '',
    );
  }
}
