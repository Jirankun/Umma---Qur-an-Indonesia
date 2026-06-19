import 'package:flutter/cupertino.dart';
import '../config/api_config.dart';
import '../models/doa.dart';
import '../services/local_storage.dart';

class DoaProvider extends ChangeNotifier {
  List<DoaItem> _bookmarks = [];
  List<DoaItem> _customDoas = [];
  List<DoaItem> _activeDoas = [];
  bool _showTranslation = true;
  bool _showArabic = true;
  String _arabSize = 'medium';

  List<DoaItem> get bookmarks => _bookmarks;
  List<DoaItem> get customDoas => _customDoas;
  List<DoaItem> get activeDoas => _activeDoas;
  bool get showTranslation => _showTranslation;
  bool get showArabic => _showArabic;
  String get arabSize => _arabSize;

  void setActiveDoas(List<DoaItem> doas) {
    _activeDoas = doas;
    notifyListeners();
  }

  Future<void> loadData() async {
    final storage = LocalStorage();

    final bookmarksJson = await storage.getJson(
      ApiConfig.storageKeyDoaBookmarks,
    );
    if (bookmarksJson != null) {
      _bookmarks = (bookmarksJson as List)
          .map((b) => DoaItem.fromJson(b))
          .toList();
    }

    final customJson = await storage.getJson(ApiConfig.storageKeyDoaCustom);
    if (customJson != null) {
      _customDoas = (customJson as List)
          .map((c) => DoaItem.fromJson(c))
          .toList();
    }

    final settingsJson = await storage.getJson(ApiConfig.storageKeyDoaSettings);
    if (settingsJson != null) {
      _showTranslation = settingsJson['showTranslation'] ?? true;
      _showArabic = settingsJson['showArabic'] ?? true;
      _arabSize = settingsJson['arabSize'] ?? 'medium';
    }

    notifyListeners();
  }

  Future<void> toggleBookmark(
    DoaItem doa, {
    String? categoryTitle,
    String? categoryId,
    String? subTabId,
  }) async {
    final updated = doa.copyWith(
      categoryTitle: categoryTitle ?? doa.categoryTitle,
      categoryId: categoryId ?? doa.categoryId,
      subTabId: subTabId ?? doa.subTabId,
    );
    if (_bookmarks.any((b) => b.id == doa.id)) {
      _bookmarks.removeWhere((b) => b.id == doa.id);
    } else {
      _bookmarks.add(updated);
    }
    await LocalStorage().saveJson(
      ApiConfig.storageKeyDoaBookmarks,
      _bookmarks.map((b) => b.toJson()).toList(),
    );
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarks.any((b) => b.id == id);

  Future<void> addCustomDoa(DoaItem doa) async {
    _customDoas.add(doa);
    await LocalStorage().saveJson(
      ApiConfig.storageKeyDoaCustom,
      _customDoas.map((c) => c.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> deleteCustomDoa(String id) async {
    _customDoas.removeWhere((c) => c.id == id);
    await LocalStorage().saveJson(
      ApiConfig.storageKeyDoaCustom,
      _customDoas.map((c) => c.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> updateSettings({
    bool? showTranslation,
    bool? showArabic,
    String? arabSize,
  }) async {
    _showTranslation = showTranslation ?? _showTranslation;
    _showArabic = showArabic ?? _showArabic;
    _arabSize = arabSize ?? _arabSize;
    await LocalStorage().saveJson(ApiConfig.storageKeyDoaSettings, {
      'showTranslation': _showTranslation,
      'showArabic': _showArabic,
      'arabSize': _arabSize,
    });
    notifyListeners();
  }
}

extension _DoaItemCopy on DoaItem {
  DoaItem copyWith({
    String? categoryTitle,
    String? categoryId,
    String? subTabId,
  }) {
    return DoaItem(
      id: id,
      title: title,
      arabic: arabic,
      latin: latin,
      translation: translation,
      source: source,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      subTabId: subTabId ?? this.subTabId,
      order: order,
    );
  }
}
