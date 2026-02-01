/// Category Model - Kategori veri modeli
class Category {
  final int id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  /// JSON'dan Category nesnesine dönüştürme
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }

  /// Category nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon};
  }
}
