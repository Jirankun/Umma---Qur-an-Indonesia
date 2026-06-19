import 'package:flutter/cupertino.dart';
import '../config/api_config.dart';
import '../models/hadits.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class HaditsProvider extends ChangeNotifier {
  List<HaditsBook> _books = [];
  bool _loading = false;
  String? _error;

  List<HaditsBook> get books => _books;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadBooks() async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService().getHaditsBooks();
      _books = data.map((b) => HaditsBook.fromJson(b)).toList();
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat kitab hadits';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

class HaditsReaderProvider extends ChangeNotifier {
  List<HaditsItem> _hadiths = [];
  List<HaditsBookmark> _bookmarks = [];
  HaditsBook? _selectedBook;
  int _page = 1;
  int _totalPages = 1;
  int jumpNumber = 0;
  String _copiedId = '';
  bool _loading = false;
  String? _error;
  HaditsSettings _settings = HaditsSettings();

  static const int _pageSize = 20;

  List<HaditsItem> get hadiths => _hadiths;
  List<HaditsBookmark> get bookmarks => _bookmarks;
  HaditsBook? get selectedBook => _selectedBook;
  int get page => _page;
  int get totalPages => _totalPages;
  String get copiedId => _copiedId;
  bool get loading => _loading;
  String? get error => _error;
  HaditsSettings get settings => _settings;

  Future<void> loadStoredData() async {
    final storage = LocalStorage();

    final bookmarksJson = await storage.getJson(
      ApiConfig.storageKeyHaditsBookmarks,
    );
    if (bookmarksJson != null) {
      _bookmarks = (bookmarksJson as List)
          .map((b) => HaditsBookmark.fromJson(b))
          .toList();
    }

    final settingsJson = await storage.getJson(
      ApiConfig.storageKeyHaditsSettings,
    );
    if (settingsJson != null) {
      _settings = HaditsSettings.fromJson(settingsJson);
    }

    notifyListeners();
  }

  Future<void> openBook(HaditsBook book, {int startPage = 1}) async {
    _selectedBook = book;
    _page = startPage;
    await fetchHadiths();
  }

  Future<void> fetchHadiths() async {
    if (_selectedBook == null) return;
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService().getHadithRange(
        book: _selectedBook!.id,
        page: _page,
        limit: _pageSize,
      );
      final items = (data['items'] as List? ?? [])
          .map((h) => HaditsItem.fromJson(h, bookSlug: _selectedBook!.id))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>?;
      _hadiths = items;
      _totalPages = pagination?['totalPages'] as int? ?? 1;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat hadits';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> changePage(int newPage) async {
    _page = newPage;
    await fetchHadiths();
  }

  Future<void> handleJumpToNumber() async {
    if (jumpNumber <= 0) return;
    _page = ((jumpNumber - 1) ~/ _pageSize) + 1;
    await fetchHadiths();
  }

  Future<void> toggleBookmark(HaditsItem hadith) async {
    if (_bookmarks.any((b) => b.hadithNumber == hadith.number)) {
      _bookmarks.removeWhere((b) => b.hadithNumber == hadith.number);
    } else {
      _bookmarks.add(
        HaditsBookmark(
          bookId: _selectedBook!.id,
          bookName: _selectedBook!.name,
          hadithNumber: hadith.number,
          hadithText: hadith.translatedId,
        ),
      );
    }
    await LocalStorage().saveJson(
      ApiConfig.storageKeyHaditsBookmarks,
      _bookmarks.map((b) => b.toJson()).toList(),
    );
    notifyListeners();
  }

  bool isBookmarked(String number) =>
      _bookmarks.any((b) => b.hadithNumber == number);

  void setCopiedId(String id) {
    _copiedId = id;
    notifyListeners();
  }

  Future<void> updateSettings(HaditsSettings settings) async {
    _settings = settings;
    await LocalStorage().saveJson(
      ApiConfig.storageKeyHaditsSettings,
      settings.toJson(),
    );
    notifyListeners();
  }
}
