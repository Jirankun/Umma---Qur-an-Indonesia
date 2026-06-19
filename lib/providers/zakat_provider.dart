import 'package:flutter/cupertino.dart';
import '../config/api_config.dart';
import '../services/local_storage.dart';

class ZakatProvider extends ChangeNotifier {
  // Zakat Fitrah
  double _berasPerJiwa = 2.5; // kg
  double _hargaBerasPerKg = 15000;
  double _jumlahJiwa = 1;

  // Zakat Maal
  double _tabungan = 0;
  double _investasi = 0;
  double _piutang = 0;
  double _hutang = 0;
  // Zakat Penghasilan
  double _penghasilanPerBulan = 0;
  double _pendapatanLain = 0;
  double _hutangPenghasilan = 0;
  double _cicilan = 0;

  // Zakat Emas & Perak
  double _emasTurun = 0; // gram emas
  double _perakTurun = 0; // gram perak

  final double nisabEmas = 85; // gram
  final double nisabPerak = 595; // gram
  final double nisabPenghasilan = 5240000; // Rp (approx)
  final double _zakatRate = 0.025; // 2.5%

  // Getters
  double get berasPerJiwa => _berasPerJiwa;
  double get hargaBerasPerKg => _hargaBerasPerKg;
  double get jumlahJiwa => _jumlahJiwa;
  double get tabungan => _tabungan;
  double get investasi => _investasi;
  double get piutang => _piutang;
  double get hutang => _hutang;
  double get penghasilanPerBulan => _penghasilanPerBulan;
  double get pendapatanLain => _pendapatanLain;
  double get hutangPenghasilan => _hutangPenghasilan;
  double get cicilan => _cicilan;
  double get emasTurun => _emasTurun;
  double get perakTurun => _perakTurun;

  // ─── PERSISTENCE ──────────────────────────────────────────────
  /// Save all zakat values to local storage
  Future<void> saveSettings() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyZakat, {
      'berasPerJiwa': _berasPerJiwa,
      'hargaBerasPerKg': _hargaBerasPerKg,
      'jumlahJiwa': _jumlahJiwa,
      'tabungan': _tabungan,
      'investasi': _investasi,
      'piutang': _piutang,
      'hutang': _hutang,
      'penghasilanPerBulan': _penghasilanPerBulan,
      'pendapatanLain': _pendapatanLain,
      'hutangPenghasilan': _hutangPenghasilan,
      'cicilan': _cicilan,
      'emasTurun': _emasTurun,
      'perakTurun': _perakTurun,
    });
  }

  /// Load saved zakat values from local storage
  Future<void> loadSavedSettings() async {
    final data = await LocalStorage().getJson(ApiConfig.storageKeyZakat);
    if (data is Map) {
      _berasPerJiwa = (data['berasPerJiwa'] as num?)?.toDouble() ?? 2.5;
      _hargaBerasPerKg = (data['hargaBerasPerKg'] as num?)?.toDouble() ?? 15000;
      _jumlahJiwa = (data['jumlahJiwa'] as num?)?.toDouble() ?? 1;
      _tabungan = (data['tabungan'] as num?)?.toDouble() ?? 0;
      _investasi = (data['investasi'] as num?)?.toDouble() ?? 0;
      _piutang = (data['piutang'] as num?)?.toDouble() ?? 0;
      _hutang = (data['hutang'] as num?)?.toDouble() ?? 0;
      _penghasilanPerBulan = (data['penghasilanPerBulan'] as num?)?.toDouble() ?? 0;
      _pendapatanLain = (data['pendapatanLain'] as num?)?.toDouble() ?? 0;
      _hutangPenghasilan = (data['hutangPenghasilan'] as num?)?.toDouble() ?? 0;
      _cicilan = (data['cicilan'] as num?)?.toDouble() ?? 0;
      _emasTurun = (data['emasTurun'] as num?)?.toDouble() ?? 0;
      _perakTurun = (data['perakTurun'] as num?)?.toDouble() ?? 0;
      notifyListeners();
    }
  }

  // Setters
  void setBerasPerJiwa(double v) {
    _berasPerJiwa = v;
    notifyListeners();
    saveSettings();
  }

  void setHargaBeras(double v) {
    _hargaBerasPerKg = v;
    notifyListeners();
    saveSettings();
  }

  void setJumlahJiwa(double v) {
    _jumlahJiwa = v;
    notifyListeners();
    saveSettings();
  }

  void setTabungan(double v) {
    _tabungan = v;
    notifyListeners();
    saveSettings();
  }

  void setInvestasi(double v) {
    _investasi = v;
    notifyListeners();
    saveSettings();
  }

  void setPiutang(double v) {
    _piutang = v;
    notifyListeners();
    saveSettings();
  }

  void setHutang(double v) {
    _hutang = v;
    notifyListeners();
    saveSettings();
  }

  void setPenghasilan(double v) {
    _penghasilanPerBulan = v;
    notifyListeners();
    saveSettings();
  }

  void setPendapatanLain(double v) {
    _pendapatanLain = v;
    notifyListeners();
    saveSettings();
  }

  void setHutangPenghasilan(double v) {
    _hutangPenghasilan = v;
    notifyListeners();
    saveSettings();
  }

  void setCicilan(double v) {
    _cicilan = v;
    notifyListeners();
    saveSettings();
  }

  void setEmasTurun(double v) {
    _emasTurun = v;
    notifyListeners();
    saveSettings();
  }

  void setPerakTurun(double v) {
    _perakTurun = v;
    notifyListeners();
    saveSettings();
  }

  // Calculations
  Map<String, dynamic> calculateFitrah() {
    final totalBeras = _berasPerJiwa * _jumlahJiwa;
    final totalUang = totalBeras * _hargaBerasPerKg;
    return {
      'totalBeras': totalBeras,
      'totalUang': totalUang,
      'perJiwa': _berasPerJiwa,
      'perJiwaUang': _berasPerJiwa * _hargaBerasPerKg,
      'isEligible': true,
    };
  }

  Map<String, dynamic> calculateMaal() {
    final totalHarta = _tabungan + _investasi + _piutang - _hutang;
    final isEligible = totalHarta >= (nisabEmas * 900000); // ~85gr emas
    final zakat = isEligible ? totalHarta * _zakatRate : 0;
    return {
      'totalHarta': totalHarta,
      'zakat': zakat,
      'isEligible': isEligible,
      'nisab': nisabEmas * 900000,
    };
  }

  Map<String, dynamic> calculatePenghasilan() {
    final totalPendapatan =
        _penghasilanPerBulan + _pendapatanLain - _hutangPenghasilan - _cicilan;
    final isEligible = totalPendapatan >= nisabPenghasilan;
    final zakat = isEligible ? totalPendapatan * _zakatRate : 0;
    return {
      'totalPendapatan': totalPendapatan,
      'zakat': zakat,
      'isEligible': isEligible,
      'nisab': nisabPenghasilan,
    };
  }

  Map<String, dynamic> calculateEmasPerak() {
    final totalEmas = _emasTurun;
    final totalPerak = _perakTurun;
    final isEligibleEmas = totalEmas >= nisabEmas;
    final isEligiblePerak = totalPerak >= nisabPerak;
    final zakatEmas = isEligibleEmas ? totalEmas * _zakatRate : 0;
    final zakatPerak = isEligiblePerak ? totalPerak * _zakatRate : 0;
    return {
      'totalEmas': totalEmas,
      'totalPerak': totalPerak,
      'zakatEmas': zakatEmas,
      'zakatPerak': zakatPerak,
      'isEligibleEmas': isEligibleEmas,
      'isEligiblePerak': isEligiblePerak,
      'nisabEmas': nisabEmas,
      'nisabPerak': nisabPerak,
    };
  }
}
