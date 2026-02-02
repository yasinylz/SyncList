import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/checklist.dart';
import '../models/item.dart';
import '../services/api_service.dart';

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
  String _filter = 'all'; // 'all', 'active', 'completed'

  @override
  void initState() {
    super.initState();
    _checklist = widget.checklist;
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final updatedChecklist = await ApiService.getChecklist(_checklist.id);
      setState(() {
        _checklist = updatedChecklist;
        _items = updatedChecklist.items;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  List<Item> get _filteredItems {
    if (_filter == 'active')
      return _items.where((i) => !i.isCompleted).toList();
    if (_filter == 'completed')
      return _items.where((i) => i.isCompleted).toList();
    return _items;
  }

  double get _progress {
    if (_items.isEmpty) return 0.0;
    return _items.where((i) => i.isCompleted).length / _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor(_progress);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: _confirmDeleteList,
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
            onPressed: _showEditListDialog, // Implement list rename
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _checklist.title,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_items.where((i) => i.isCompleted).length} / ${_items.length} tamamlandı",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                    ),
                    Text(
                      "${(_progress * 100).toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("Hepsi", 'all'),
                const SizedBox(width: 8),
                _buildFilterChip("Yapılacaklar", 'active'),
                const SizedBox(width: 8),
                _buildFilterChip("Tamamlananlar", 'completed'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildItemTile(theme, item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text("Madde Ekle"),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 16),
          Text(
            "Gösterilecek madde yok",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ThemeData theme, Item item) {
    final isCompleted = item.isCompleted;
    return Dismissible(
      key: Key(item.id.toString()),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteItem(item),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCompleted
                ? Colors.transparent
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: ListTile(
          onTap: () => _toggleItem(item),
          leading: GestureDetector(
            onTap: () => _toggleItem(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? Colors.green : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            item.taskName,
            style: TextStyle(
              fontSize: 16,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted
                  ? theme.colorScheme.outline
                  : theme.colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: theme.colorScheme.outline,
                onPressed: () => _showEditItemDialog(item),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => _deleteItem(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.purple;
  }

  Future<void> _toggleItem(Item item) async {
    try {
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {}
      });

      await ApiService.toggleItem(item.id);
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _deleteItem(Item item) async {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });

    try {
      await ApiService.deleteItem(item.id);
    } catch (e) {
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Silinemedi: $e')));
      }
    }
  }

  Future<void> _confirmDeleteList() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Listeyi Sil"),
        content: const Text(
          "Bu listeyi ve tüm maddelerini silmek istiyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteChecklist(_checklist.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _showAddItemDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Madde"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Örn: Süt al"),
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.isNotEmpty)
              Navigator.pop(context, controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty)
                Navigator.pop(context, controller.text);
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    ).then((value) async {
      if (value != null && value is String) {
        try {
          await ApiService.createItem(value, _checklist.id);
          _loadItems();
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    });
  }

  Future<void> _showEditItemDialog(Item item) async {
    final controller = TextEditingController(text: item.taskName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Maddeyi Düzenle"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Madde Adı"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty)
                Navigator.pop(context, controller.text);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    ).then((value) async {
      if (value != null && value is String) {
        try {
          await ApiService.updateItem(item.id, value);
          _loadItems();
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    });
  }

  Future<void> _showEditListDialog() async {
    final titleController = TextEditingController(text: _checklist.title);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Listeyi Yeniden Adlandır"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Liste Adı"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty)
                Navigator.pop(context, titleController.text);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    ).then((value) async {
      if (value != null && value is String) {
        try {
          await ApiService.updateChecklist(
            _checklist.id,
            value,
            _checklist.categoryId,
          );
          _loadItems();
          setState(() {});
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    });
  }
}
