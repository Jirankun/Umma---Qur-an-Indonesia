import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/local_storage.dart';
import '../config/api_config.dart';

class HaidProvider extends ChangeNotifier {
  List<HaidLog> _logs = [];
  bool _loading = false;

  List<HaidLog> get logs => _logs;
  bool get loading => _loading;

  HaidLog? get activePeriod {
    return _logs.where((l) => l.endDate == null).firstOrNull;
  }

  int get totalMissedFasting {
    int total = 0;
    for (final log in _logs) {
      total += log.qadhaDays;
    }
    return total;
  }

  Future<void> loadData() async {
    _loading = true;
    notifyListeners();

    final storage = LocalStorage();
    final data = await storage.getJson(ApiConfig.storageKeyHaid);
    if (data != null) {
      _logs = (data['logs'] as List? ?? [])
          .map((l) => HaidLog.fromJson(l))
          .toList();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveDate(String type, DateTime date) async {
    if (type == 'start') {
      _logs.add(
        HaidLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startDate: date,
        ),
      );
    } else if (type == 'end') {
      final active = activePeriod;
      if (active != null) {
        final index = _logs.indexOf(active);
        _logs[index] = HaidLog(
          id: active.id,
          startDate: active.startDate,
          endDate: date,
        );
      }
    }

    await _persist();
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    await _persist();
    notifyListeners();
  }

  int getDuration(HaidLog log) {
    if (log.endDate == null) {
      return DateTime.now().difference(log.startDate).inDays + 1;
    }
    return log.endDate!.difference(log.startDate).inDays + 1;
  }

  int getQadhaDays(HaidLog log) {
    return getDuration(log);
  }

  String getCyclePhase() {
    if (activePeriod != null) {
      return 'haid';
    }

    // Check recently ended cycle
    final recentEnded = _logs.where((l) => l.endDate != null).toList()
      ..sort((a, b) => b.endDate!.compareTo(a.endDate!));

    if (recentEnded.isNotEmpty) {
      final daysSinceEnd = DateTime.now()
          .difference(recentEnded.first.endDate!)
          .inDays;
      if (daysSinceEnd <= 14) return 'subur';
      if (daysSinceEnd <= 28) return 'luteal';
    }

    return 'folikular';
  }

  Future<void> _persist() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyHaid, {
      'logs': _logs.map((l) => l.toJson()).toList(),
    });
  }
}
