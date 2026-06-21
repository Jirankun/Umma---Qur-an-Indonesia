import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/ai_content_service.dart';
import '../data/fiqih_data.dart';

class FiqihProvider extends ChangeNotifier {
  static const String kategoriSemua = 'semua';

  List<FiqihItem> _allItems = [];
  List<FiqihItem> _filteredItems = [];
  String _activeCategory = kategoriSemua; // default: 'semua'
  String _searchQuery = '';
  String _selectedItemId = '';
  bool _isLoading = true;

  List<FiqihItem> get allItems => _allItems;
  List<FiqihItem> get filteredItems => _filteredItems;
  String get activeCategory => _activeCategory;
  String get searchQuery => _searchQuery;
  String get selectedItemId => _selectedItemId;
  bool get isLoading => _isLoading;

  /// Daftar kategori termasuk 'semua' di posisi pertama
  List<String> get categories {
    final catSet = _allItems.map((i) => i.category).toSet().toList()..sort();
    return [kategoriSemua, ...catSet];
  }

  int getItemCount(String category) {
    if (category == kategoriSemua) return _allItems.length;
    return _allItems.where((i) => i.category == category).length;
  }

  /// Load konten Fiqih — PRIORITAS: offline data (124+ item) + AI supplement
  Future<void> loadContent() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load offline data selalu sebagai base (124+ item)
      _allItems = _parseFiqihData(fiqihOfflineData);

      // 2. Coba supplement dengan AI content (jika cache/API tersedia)
      final aiItems = await AiContentService().getFiqihItems();
      if (aiItems.length > 5) {
        // Gabung: AI items + offline items, dedup by id
        final seenIds = _allItems.map((i) => i.id).toSet();
        for (final item in aiItems) {
          final id = (item['id'] as String?) ?? '';
          if (!seenIds.contains(id)) {
            _allItems.add(FiqihItem(
              id: id,
              title: (item['title'] as String?) ?? '',
              content: (item['content'] as String?) ?? '',
              category: (item['category'] as String?)?.toLowerCase() ?? 'umum',
              reference: (item['source'] as String?) ??
                  (item['reference'] as String?),
            ));
            seenIds.add(id);
          }
        }
      }
    } catch (_) {
      // Fallback: offline data saja
      _allItems = _parseFiqihData(fiqihOfflineData);
    }

    _isLoading = false;
    _filteredItems = [];
    notifyListeners();
  }

  List<FiqihItem> _parseFiqihData(List<Map<String, dynamic>> data) {
    return data.map((m) {
      return FiqihItem(
        id: (m['id'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?)?.toLowerCase() ?? 'umum',
        reference: m['reference'] as String?,
      );
    }).toList();
  }

  void filterByCategory(String category) {
    _activeCategory = category;
    _searchQuery = '';
    if (category == kategoriSemua) {
      _filteredItems = []; // menandakan show all
    } else {
      _filteredItems = _allItems.where((i) => i.category == category).toList();
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _activeCategory = kategoriSemua;
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _allItems
          .where(
            (i) =>
                i.title.toLowerCase().contains(query.toLowerCase()) ||
                i.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void clearFilter() {
    _activeCategory = kategoriSemua;
    _searchQuery = '';
    _filteredItems = [];
    _selectedItemId = '';
    notifyListeners();
  }

  void selectItem(String id) {
    _selectedItemId = id;
    notifyListeners();
  }
}
