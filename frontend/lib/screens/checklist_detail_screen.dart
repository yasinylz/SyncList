import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../models/item.dart';
import '../services/api_service.dart';

/// Liste Detay Ekranı - Kontrol listesinin maddelerini gösteren ekran
class ChecklistDetailScreen extends StatefulWidget {
  final Checklist checklist;

  const ChecklistDetailScreen({super.key, required this.checklist});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  late Checklist _checklist;
  List<Item> _items = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all'; // 'all', 'completed', 'incomplete'
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _checklist = widget.checklist;
    _loadItems();
  }

  /// Maddeleri yükle
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final checklist = await ApiService.getChecklist(_checklist.id);
      setState(() {
        _checklist = checklist;
        _items = checklist.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Filtrelenmiş maddeler
  List<Item> get _filteredItems {
    if (_filterStatus == 'completed') {
      return _items.where((item) => item.isCompleted).toList();
    } else if (_filterStatus == 'incomplete') {
      return _items.where((item) => !item.isCompleted).toList();
    }
    return _items;
  }

  /// İlerleme hesapla
  double get _progress => _items.isEmpty
      ? 0.0
      : _items.where((i) => i.isCompleted).length / _items.length;

  int get _completedCount => _items.where((i) => i.isCompleted).length;

  /// Madde tamamlanma durumunu değiştir
  Future<void> _toggleItem(Item item) async {
    try {
      await ApiService.toggleItem(item.id);
      _loadItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Yeni madde ekleme dialogu
  Future<void> _showAddItemDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: Colors.teal),
            SizedBox(width: 8),
            Text('Yeni Madde Ekle'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Madde Adı',
            hintText: 'Örn: Ayakkabı, Gömlek...',
            prefixIcon: Icon(Icons.task_alt),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) async {
            if (controller.text.trim().isNotEmpty) {
              try {
                await ApiService.createItem(
                  controller.text.trim(),
                  _checklist.id,
                );
                Navigator.pop(context);
                _loadItems();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await ApiService.createItem(
                    controller.text.trim(),
                    _checklist.id,
                  );
                  Navigator.pop(context);
                  _loadItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Madde eklendi! ✓'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  /// Madde düzenleme dialogu
  Future<void> _showEditItemDialog(Item item) async {
    final controller = TextEditingController(text: item.taskName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 8),
            Text('Maddeyi Düzenle'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Madde Adı',
            prefixIcon: Icon(Icons.task_alt),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await ApiService.updateItem(item.id, controller.text.trim());
                  Navigator.pop(context);
                  _loadItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Madde güncellendi! ✓'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  /// Madde silme onay dialogu
  Future<void> _confirmDeleteItem(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Maddeyi Sil'),
          ],
        ),
        content: Text(
          '"${item.taskName}" maddesini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteItem(item.id);
        _loadItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Madde silindi'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Liste silme onay dialogu
  Future<void> _confirmDeleteChecklist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Listeyi Sil'),
          ],
        ),
        content: Text(
          '"${_checklist.title}" listesini ve tüm maddelerini silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text(
              'Listeyi Sil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteChecklist(_checklist.id);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liste silindi'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Madde kartı widget'ı
  Widget _buildItemTile(Item item) {
    return Dismissible(
      key: Key('item-${item.id}'),
      direction: _isEditing
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _confirmDeleteItem(item),
      confirmDismiss: (_) async => _isEditing,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: GestureDetector(
            onTap: () => _toggleItem(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? Colors.green
                    : Colors.teal.withOpacity(0.1),
                border: Border.all(
                  color: item.isCompleted
                      ? Colors.green
                      : Colors.teal.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          title: Text(
            item.taskName,
            style: TextStyle(
              fontSize: 16,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              color: item.isCompleted
                  ? Colors.grey
                  : null, // Siyah yerine null (tema rengi)
            ),
          ),
          trailing: _isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditItemDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteItem(item),
                    ),
                  ],
                )
              : item.isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _progress == 1.0
        ? Colors.green
        : _progress > 0.5
        ? Colors.orange
        : Colors.teal;

    return Scaffold(
      // backgroundColor: Colors.grey.shade100, // Temadan gelmeli
      appBar: AppBar(
        title: Text(_checklist.title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Düzenleme modu
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            tooltip: _isEditing ? 'Düzenlemeyi Bitir' : 'Düzenle',
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          // Silme butonu
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Listeyi Sil',
            onPressed: _confirmDeleteChecklist,
          ),
          // Yenileme butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // İlerleme kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [progressColor.withOpacity(0.8), progressColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: progressColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // İlerleme göstergesi
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '%${(_progress * 100).round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _checklist.category?.name ?? 'Genel',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _progress == 1.0 ? 'Tamamlandı! 🎉' : 'Devam Ediyor...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_completedCount / ${_items.length} madde',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filtre butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('Tümü', 'all'),
                const SizedBox(width: 8),
                _buildFilterButton('Tamamlanan', 'completed'),
                const SizedBox(width: 8),
                _buildFilterButton('Bekleyen', 'incomplete'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Maddeler listesi
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadItems,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _filterStatus == 'all'
                              ? Icons.inbox_outlined
                              : Icons.filter_list_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'all'
                              ? 'Henüz madde yok'
                              : 'Filtreye uygun madde yok',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_filterStatus == 'all') ...[
                          const SizedBox(height: 8),
                          Text(
                            '+ butonuna tıklayarak madde ekleyin',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadItems,
                    color: Colors.teal,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) =>
                          _buildItemTile(_filteredItems[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Madde Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String status) {
    final isSelected = _filterStatus == status;
    return OutlinedButton(
      onPressed: () => setState(() => _filterStatus = status),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.teal,
        side: const BorderSide(color: Colors.teal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
