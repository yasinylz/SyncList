import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/checklist.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'checklist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Checklist> _checklists = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final checklists = await ApiService.getChecklists();
      final categories = await ApiService.getCategories();
      setState(() {
        _checklists = checklists;
        _categories = categories;
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

  List<Checklist> get _filteredChecklists {
    if (_selectedCategoryId == null) return _checklists;
    return _checklists
        .where((c) => c.categoryId == _selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Arka Plan Resmi
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Ana İçerik
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(theme),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Kategoriler",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildCategoriesList(theme)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Listelerim",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_filteredChecklists.length} Liste",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildChecklistsGrid(theme),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Liste"),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor:
          Colors.transparent, // Transparent for background visibility
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'SyncList',
          style: GoogleFonts.outfit(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.category_outlined),
          onPressed: _showManageCategoriesDialog,
          tooltip: "Kategorileri Yönet",
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
    );
  }

  Widget _buildCategoriesList(ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              theme,
              null,
              "Tümü",
              "🔍",
              isSelected: _selectedCategoryId == null,
            );
          }
          final cat = _categories[index - 1];
          return GestureDetector(
            onLongPress: () => _showEditDeleteCategoryOptions(cat),
            child: _buildCategoryChip(
              theme,
              cat.id,
              cat.name,
              cat.icon,
              isSelected: _selectedCategoryId == cat.id,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    ThemeData theme,
    int? id,
    String name,
    String? icon, {
    required bool isSelected,
  }) {
    final color = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCategoryId = id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon ?? "📁", style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistsGrid(ThemeData theme) {
    if (_filteredChecklists.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.checklist_rtl_rounded,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  "Bu kategoride liste yok",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final list = _filteredChecklists[index];
          return _buildChecklistCard(theme, list);
        }, childCount: _filteredChecklists.length),
      ),
    );
  }

  Widget _buildChecklistCard(ThemeData theme, Checklist list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistDetailScreen(checklist: list),
            ),
          );
          _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  list.category?.icon ?? "📝",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${list.completedCount}/${list.totalCount} tamamlandı",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: list.progress,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(list.progress),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${list.progressPercent}%",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  // --- Dialogs ---

  Future<void> _showCreateListDialog() async {
    final titleController = TextEditingController();
    int? selectedCategory = _selectedCategoryId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Yeni Liste Oluştur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Liste Adı",
                  hintText: "Örn: Market Alışverişi",
                  prefixIcon: Icon(Icons.title),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Kategorisiz"),
                  ),
                  ..._categories.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text("${c.icon ?? ''} ${c.name}"),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => selectedCategory = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  try {
                    await ApiService.createChecklist(
                      titleController.text,
                      selectedCategory,
                    );
                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Hata: $e")));
                  }
                }
              },
              child: const Text("Oluştur"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManageCategoriesDialog() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kategorileri Yönet"),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.teal),
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateCategoryDialog();
                },
                tooltip: "Yeni Kategori Ekle",
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Henüz kategori yok.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return ListTile(
                        leading: Text(
                          cat.icon ?? "📁",
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(cat.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditCategoryDialog(cat);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Confirm delete inside this dialog context?
                                // Better to close and show confirm.
                                Navigator.pop(context);
                                _confirmDeleteCategory(cat);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kapat"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateCategoryDialog() async {
    final nameController = TextEditingController();
    String selectedIcon = "📁";
    final icons = ["📁", "🏠", "✈️", "🛒", "💻", "🎓", "🎮", "🎵", "🏥", "🔧"];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Yeni Kategori"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Kategori Adı",
                  hintText: "Örn: İş",
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: icons.map((icon) {
                  return InkWell(
                    onTap: () => setState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(color: Theme.of(context).primaryColor)
                            : Border.all(color: Colors.grey.shade300),
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
              child: const Text("İptal"),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await ApiService.createCategory(
                      nameController.text,
                      selectedIcon,
                    );
                    Navigator.pop(context);
                    // Re-open manage dialog to show new category is nice, but lets just load data
                    _loadData();
                    // Optional: Re-open manage dialog? No, keep it simple.
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Hata: $e")));
                  }
                }
              },
              child: const Text("Oluştur"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeleteCategoryOptions(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Düzenle"),
            onTap: () {
              Navigator.pop(context);
              _showEditCategoryDialog(category);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Sil", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              _confirmDeleteCategory(category);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCategoryDialog(Category category) async {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon ?? "📁";
    final icons = ["📁", "🏠", "✈️", "🛒", "💻", "🎓", "🎮", "🎵", "🏥", "🔧"];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Kategoriyi Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Kategori Adı"),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: icons.map((icon) {
                  return InkWell(
                    onTap: () => setState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(color: Theme.of(context).primaryColor)
                            : Border.all(color: Colors.grey.shade300),
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
              child: const Text("İptal"),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await ApiService.updateCategory(
                      category.id,
                      nameController.text,
                      selectedIcon,
                    );
                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Hata: $e")));
                  }
                }
              },
              child: const Text("Güncelle"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kategoriyi Sil"),
        content: Text("${category.name} kategorisini silmek istiyor musunuz?"),
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
        await ApiService.deleteCategory(category.id);
        _selectedCategoryId = null; // Sıfırla
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Hata: $e")));
        }
      }
    }
  }
}
