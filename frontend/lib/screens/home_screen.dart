import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'checklist_detail_screen.dart';

/// Ana Sayfa - Tüm kontrol listelerini gösteren ekran
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Checklist> _checklists = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all'; // 'all', 'completed', 'incomplete'
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final checklists = await ApiService.getChecklists();
      final categories = await ApiService.getCategories();
      setState(() {
        _checklists = checklists;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Filtrelenmiş listeleri getir
  List<Checklist> get _filteredChecklists {
    var filtered = _checklists;

    // Kategori filtresi
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((c) => c.categoryId == _selectedCategoryId)
          .toList();
    }

    // Durum filtresi
    if (_filterStatus == 'completed') {
      filtered = filtered.where((c) => c.progress == 1.0).toList();
    } else if (_filterStatus == 'incomplete') {
      filtered = filtered.where((c) => c.progress < 1.0).toList();
    }

    return filtered;
  }

  /// Yeni liste oluşturma dialogu
  Future<void> _showCreateListDialog() async {
    final titleController = TextEditingController();
    int? selectedCategory;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_task, color: Colors.teal),
              SizedBox(width: 8),
              Text('Yeni Liste Oluştur'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Liste Adı',
                  hintText: 'Örn: Yaz Tatili Bavulu',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori (Opsiyonel)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Kategorisiz'),
                  ),
                  ..._categories.map(
                    (cat) => DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedCategory = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  try {
                    await ApiService.createChecklist(
                      titleController.text.trim(),
                      selectedCategory,
                    );
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liste oluşturuldu! ✓'),
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
              icon: const Icon(Icons.check),
              label: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori oluşturma dialogu
  Future<void> _showCreateCategoryDialog() async {
    final nameController = TextEditingController();
    String selectedIcon = '📋';

    final icons = ['📋', '✈️', '🛒', '💼', '🏠', '🎯', '📚', '🎮', '🏃', '🍳'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.category, color: Colors.orange),
              SizedBox(width: 8),
              Text('Yeni Kategori'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Kategori Adı',
                  hintText: 'Örn: Seyahat',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('İkon Seç:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: icons.map((icon) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest, // Tema uyumlu renk
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(color: Colors.teal, width: 2)
                            : null,
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  try {
                    await ApiService.createCategory(
                      nameController.text.trim(),
                      selectedIcon,
                    );
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kategori oluşturuldu! ✓'),
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
              icon: const Icon(Icons.check),
              label: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  /// Liste kartı widget'ı
  Widget _buildChecklistCard(Checklist checklist) {
    final progressColor = checklist.progress == 1.0
        ? Colors.green
        : checklist.progress > 0.5
        ? Colors.orange
        : Colors.teal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistDetailScreen(checklist: checklist),
            ),
          );
          _loadData(); // Geri dönünce verileri güncelle
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Kategori ikonu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      checklist.category?.icon ?? '📋',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Başlık ve kategori
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checklist.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (checklist.category != null)
                          Text(
                            checklist.category!.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // İlerleme yüzdesi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '%${checklist.progressPercent}',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // İlerleme çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: checklist.progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              // Madde sayısı
              Text(
                '${checklist.completedCount} / ${checklist.totalCount} madde tamamlandı',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade100, // Temadan gelmeli
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.checklist_rounded, size: 28),
            SizedBox(width: 8),
            Text('SyncList'),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Kategori ekleme butonu
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Kategori Ekle',
            onPressed: _showCreateCategoryDialog,
          ),
          // Yenileme butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka Plan Resmi
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, // Çok hafif görünmesi için
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Ana İçerik
          SafeArea(
            child: Column(
              children: [
                // Filtre bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal.shade50.withOpacity(
                    0.8,
                  ), // Hafif transparan
                  child: Column(
                    children: [
                      // Kategori filtresi
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'Tümü',
                              isSelected: _selectedCategoryId == null,
                              onTap: () =>
                                  setState(() => _selectedCategoryId = null),
                            ),
                            ..._categories.map(
                              (cat) => _buildFilterChip(
                                label: '${cat.icon ?? ""} ${cat.name}',
                                isSelected: _selectedCategoryId == cat.id,
                                onTap: () => setState(
                                  () => _selectedCategoryId = cat.id,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Durum filtresi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusChip('Tümü', 'all'),
                          _buildStatusChip('Tamamlanan', 'completed'),
                          _buildStatusChip('Devam Eden', 'incomplete'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Liste içeriği
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
                              Text(
                                'Bağlantı Hatası',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(_error!),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        )
                      : _filteredChecklists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz liste yok',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yeni bir liste oluşturmak için + butonuna tıklayın',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: Colors.teal,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredChecklists.length,
                            itemBuilder: (context, index) =>
                                _buildChecklistCard(_filteredChecklists[index]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Yeni Liste',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.teal.shade200,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterStatus = status),
        selectedColor: Colors.teal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 12,
        ),
      ),
    );
  }
}
