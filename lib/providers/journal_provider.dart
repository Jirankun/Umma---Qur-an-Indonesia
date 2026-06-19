import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/local_storage.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _loading = false;

  List<JournalEntry> get entries => _entries;
  bool get loading => _loading;

  Future<void> loadJournals() async {
    _loading = true;
    notifyListeners();

    final storage = LocalStorage();
    final data = await storage.getJournals();
    if (data != null) {
      _entries = data.map((j) => JournalEntry.fromJson(j)).toList();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveJournal(JournalEntry entry) async {
    final existingIndex = _entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex >= 0) {
      _entries[existingIndex] = entry;
    } else {
      _entries.insert(0, entry);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  JournalEntry? getEntryById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<JournalEntry> getFiltered({String? category, String? date}) {
    return _entries.where((e) {
      final matchCategory =
          category == null || category == 'all' || e.category == category;
      final matchDate =
          date == null ||
          date == 'all' ||
          '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}' ==
              date;
      return matchCategory && matchDate;
    }).toList();
  }

  Future<void> _persist() async {
    await LocalStorage().saveJournals(_entries.map((e) => e.toJson()).toList());
  }
}
