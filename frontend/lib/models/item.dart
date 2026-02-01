/// Item Model - Madde/Görev veri modeli
class Item {
  final int id;
  final String taskName;
  final bool isCompleted;
  final int checklistId;

  Item({
    required this.id,
    required this.taskName,
    required this.isCompleted,
    required this.checklistId,
  });

  /// JSON'dan Item nesnesine dönüştürme
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      taskName: json['taskName'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      checklistId: json['checklistId'],
    );
  }

  /// Item nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted,
      'checklistId': checklistId,
    };
  }

  /// Item'ın tamamlanma durumunu değiştirmek için kopyasını oluştur
  Item copyWith({bool? isCompleted, String? taskName}) {
    return Item(
      id: id,
      taskName: taskName ?? this.taskName,
      isCompleted: isCompleted ?? this.isCompleted,
      checklistId: checklistId,
    );
  }
}
