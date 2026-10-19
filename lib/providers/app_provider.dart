import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/weighing_models.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final TtsService _tts = TtsService();
  final Uuid _uuid = const Uuid();

  List<WeighingSession> _sessions = [];
  List<PartnerContact> _contacts = [];
  List<SeasonBatch> _seasons = [];
  String _selectedSeasonId = 'all';

  bool _autoOneDecimal = true;
  bool _voiceEnabled = true;
  bool _isDarkMode = false;
  bool _isLoading = true;

  List<WeighingSession> get sessions => _sessions;
  List<PartnerContact> get contacts => _contacts;
  List<SeasonBatch> get seasons => _seasons;
  String get selectedSeasonId => _selectedSeasonId;
  bool get autoOneDecimal => _autoOneDecimal;
  bool get voiceEnabled => _voiceEnabled;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  List<WeighingSession> get filteredSessions {
    if (_selectedSeasonId == 'all') return _sessions;
    return _sessions.where((s) => s.seasonId == _selectedSeasonId).toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _seasons = await _storage.loadSeasons();
    _contacts = await _storage.loadContacts();
    _sessions = await _storage.loadSessions();
    _autoOneDecimal = await _storage.loadAutoOneDecimal();
    _voiceEnabled = await _storage.loadVoiceEnabled();
    _isDarkMode = await _storage.loadDarkMode();

    if (_seasons.isNotEmpty) {
      _selectedSeasonId = _seasons.first.id;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedSeasonId(String seasonId) {
    _selectedSeasonId = seasonId;
    notifyListeners();
  }

  Future<void> toggleAutoOneDecimal() async {
    _autoOneDecimal = !_autoOneDecimal;
    await _storage.saveAutoOneDecimal(_autoOneDecimal);
    notifyListeners();
  }

  Future<void> toggleVoiceEnabled() async {
    _voiceEnabled = !_voiceEnabled;
    await _storage.saveVoiceEnabled(_voiceEnabled);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Tạo phiếu cân mới với thông số mặc định chuẩn cho Lúa hoặc Heo
  Future<WeighingSession> createNewSession({
    required SessionType type,
    required String title,
    String partnerId = '',
    required String partnerName,
    String partnerPhone = '',
    required double pricePerKg,
    int rowsPerColumn = 5,
  }) async {
    final now = DateTime.now();
    final seasonId = _selectedSeasonId == 'all'
        ? (_seasons.isNotEmpty ? _seasons.first.id : 'default')
        : _selectedSeasonId;

    final newSession = WeighingSession(
      id: _uuid.v4(),
      title: title.trim().isEmpty
          ? (type == SessionType.rice ? 'Phiếu cân lúa mới' : 'Phiếu cân heo mới')
          : title.trim(),
      type: type,
      seasonId: seasonId,
      partnerId: partnerId,
      partnerName: partnerName.trim().isEmpty ? 'Khách lẻ' : partnerName.trim(),
      partnerPhone: partnerPhone.trim(),
      createdAt: now,
      updatedAt: now,
      rowsPerColumn: rowsPerColumn,
      entries: [],
      tareMode:
          type == SessionType.rice ? TareMode.bagsPerKg : TareMode.kgPerUnit,
      tareValue: type == SessionType.rice ? 8.0 : 12.0,
      pricePerKg: pricePerKg,
    );

    _sessions.insert(0, newSession);
    await _storage.saveSessions(_sessions);
    notifyListeners();
    return newSession;
  }

  WeighingSession? getSessionById(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateSession(WeighingSession updated) async {
    final idx = _sessions.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;
    _sessions[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _storage.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _storage.saveSessions(_sessions);
    notifyListeners();
  }

  /// Thêm một mã cân mới vào phiếu
  Future<void> addWeighingEntry(
    String sessionId, {
    required double weight,
    int headCount = 1,
    String note = '',
  }) async {
    final session = getSessionById(sessionId);
    if (session == null) return;

    final entry = WeighingEntry(
      id: _uuid.v4(),
      weight: weight,
      headCount: headCount,
      timestamp: DateTime.now(),
      note: note,
    );

    final updatedEntries = List<WeighingEntry>.from(session.entries)..add(entry);
    final updatedSession = session.copyWith(entries: updatedEntries);
    await updateSession(updatedSession);

    if (_voiceEnabled) {
      await _tts.speakWeight(
        weight,
        isPig: session.type == SessionType.pig,
      );
    }
  }

  /// Sửa một mã cân đã nhập
  Future<void> editWeighingEntry(
    String sessionId, {
    required String entryId,
    required double newWeight,
    int? newHeadCount,
    String? newNote,
  }) async {
    final session = getSessionById(sessionId);
    if (session == null) return;

    final updatedEntries = session.entries.map((e) {
      if (e.id == entryId) {
        return e.copyWith(
          weight: newWeight,
          headCount: newHeadCount,
          note: newNote,
        );
      }
      return e;
    }).toList();

    await updateSession(session.copyWith(entries: updatedEntries));
  }

  /// Xoá một mã cân
  Future<void> removeWeighingEntry(String sessionId, String entryId) async {
    final session = getSessionById(sessionId);
    if (session == null) return;

    final updatedEntries =
        session.entries.where((e) => e.id != entryId).toList();
    await updateSession(session.copyWith(entries: updatedEntries));
  }

  /// Xoá mã cân cuối cùng vừa bấm nhầm
  Future<void> undoLastEntry(String sessionId) async {
    final session = getSessionById(sessionId);
    if (session == null || session.entries.isEmpty) return;

    final updatedEntries = List<WeighingEntry>.from(session.entries)
      ..removeLast();
    await updateSession(session.copyWith(entries: updatedEntries));
  }

  /// Quản lý Danh bạ Nông dân / Thương lái
  Future<void> addContact({
    required String name,
    required String phone,
    required String role,
    String address = '',
    String note = '',
  }) async {
    final contact = PartnerContact(
      id: _uuid.v4(),
      name: name.trim(),
      phone: phone.trim(),
      role: role,
      address: address.trim(),
      note: note.trim(),
    );
    _contacts.insert(0, contact);
    await _storage.saveContacts(_contacts);
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _storage.saveContacts(_contacts);
    notifyListeners();
  }

  /// Quản lý Mùa vụ / Đợt cân
  Future<void> addSeason(String name, {String note = ''}) async {
    final season = SeasonBatch(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: DateTime.now(),
      note: note.trim(),
    );
    _seasons.insert(0, season);
    _selectedSeasonId = season.id;
    await _storage.saveSeasons(_seasons);
    notifyListeners();
  }
}
