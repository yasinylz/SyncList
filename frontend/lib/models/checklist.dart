import 'category.dart';
import 'item.dart';

/// Checklist Model - Kontrol listesi veri modeli
class Checklist {
  final int id;
  final String title;
  final int? categoryId;
  final Category? category;
  final List<Item> items;

  Checklist({
    required this.id,
    required this.title,
    this.categoryId,
    this.category,
    this.items = const [],
  });

  /// JSON'dan Checklist nesnesine dönüştürme
  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'],
      title: json['title'] ?? '',
      categoryId: json['categoryId'],
      category: json['Category'] != null
          ? Category.fromJson(json['Category'])
          : null,
      items: json['Items'] != null
          ? (json['Items'] as List).map((item) => Item.fromJson(item)).toList()
          : [],
    );
  }

  /// Checklist nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'categoryId': categoryId};
  }

  /// Tamamlanmış madde sayısı
  int get completedCount => items.where((item) => item.isCompleted).length;

  /// Toplam madde sayısı
  int get totalCount => items.length;

  /// İlerleme yüzdesi (0.0 - 1.0)
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  /// İlerleme yüzdesi (0 - 100)
  int get progressPercent => (progress * 100).round();
}
