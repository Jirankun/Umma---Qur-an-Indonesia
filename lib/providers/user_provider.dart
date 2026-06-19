import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/local_storage.dart';
import '../config/api_config.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _loading = false;
  final bool _isLoggedIn = true; // Local-first: always logged in

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadProfile() async {
    _loading = true;
    notifyListeners();

    final storage = LocalStorage();
    final data = await storage.getJson(ApiConfig.storageKeyUser);
    if (data != null) {
      _profile = UserProfile.fromJson(data);
    } else {
      _profile = UserProfile(username: 'Hamba Allah', locationCity: 'Jakarta');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await LocalStorage().saveJson(ApiConfig.storageKeyUser, profile.toJson());
    notifyListeners();
  }

  Future<void> updateUsername(String name) async {
    _profile ??= UserProfile();
    _profile!.username = name;
    await LocalStorage().saveJson(ApiConfig.storageKeyUser, _profile!.toJson());
    notifyListeners();
  }

  Future<void> updateCity(String city) async {
    _profile ??= UserProfile();
    _profile!.locationCity = city;
    await LocalStorage().saveJson(ApiConfig.storageKeyUser, _profile!.toJson());
    notifyListeners();
  }

  Future<void> addCustomHabit(CustomHabit habit) async {
    _profile ??= UserProfile();
    _profile!.customHabits.add(habit);
    await LocalStorage().saveJson(ApiConfig.storageKeyUser, _profile!.toJson());
    notifyListeners();
  }

  Future<void> removeCustomHabit(String id) async {
    _profile?.customHabits.removeWhere((h) => h.id == id);
    if (_profile != null) {
      await LocalStorage().saveJson(
        ApiConfig.storageKeyUser,
        _profile!.toJson(),
      );
    }
    notifyListeners();
  }
}
