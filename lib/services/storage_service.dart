import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weighing_models.dart';

class StorageService {
  static const String _keySessions = 'weighing_sessions_v1';
  static const String _keyContacts = 'partner_contacts_v1';
  static const String _keySeasons = 'season_batches_v1';
  static const String _keyAutoDecimal = 'setting_auto_decimal_v1';
  static const String _keyVoiceEnabled = 'setting_voice_enabled_v1';
  static const String _keyDarkMode = 'setting_dark_mode_v1';

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<List<WeighingSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySessions);
    if (raw == null || raw.isEmpty) {
      final demo = _createDemoSessions();
      await saveSessions(demo);
      return demo;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => WeighingSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<WeighingSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_keySessions, encoded);
  }

  Future<List<PartnerContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyContacts);
    if (raw == null || raw.isEmpty) {
      final demo = _createDemoContacts();
      await saveContacts(demo);
      return demo;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => PartnerContact.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveContacts(List<PartnerContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_keyContacts, encoded);
  }

  Future<List<SeasonBatch>> loadSeasons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySeasons);
    if (raw == null || raw.isEmpty) {
      final demo = _createDemoSeasons();
      await saveSeasons(demo);
      return demo;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => SeasonBatch.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSeasons(List<SeasonBatch> seasons) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(seasons.map((s) => s.toJson()).toList());
    await prefs.setString(_keySeasons, encoded);
  }

  Future<bool> loadAutoOneDecimal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoDecimal) ?? true;
  }

  Future<void> saveAutoOneDecimal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoDecimal, value);
  }

  Future<bool> loadVoiceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVoiceEnabled) ?? true;
  }

  Future<void> saveVoiceEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoiceEnabled, value);
  }

  List<SeasonBatch> _createDemoSeasons() {
    final now = DateTime.now();
    return [
      SeasonBatch(
        id: 'season_1',
        name: 'Vụ Đông Xuân ${now.year}',
        createdAt: now.subtract(const Duration(days: 5)),
        note: 'Thu mua lúa tươi tại ruộng và xuất heo thịt',
      ),
      SeasonBatch(
        id: 'season_2',
        name: 'Vụ Hè Thu ${now.year}',
        createdAt: now.subtract(const Duration(days: 30)),
        note: 'Đợt thu mua trước',
      ),
    ];
  }

  List<PartnerContact> _createDemoContacts() {
    return [
      PartnerContact(
        id: 'contact_1',
        name: 'Chú Bảy Thành',
        phone: '0918234567',
        role: 'Nông dân',
        address: 'Ấp 3, Tháp Mười, Đồng Tháp',
        note: 'Ruộng lúa Đài Thơm 8 gần kênh lớn',
      ),
      PartnerContact(
        id: 'contact_2',
        name: 'Anh Tư Sang',
        phone: '0909876543',
        role: 'Chủ trại',
        address: 'Trảng Bom, Đồng Nai',
        note: 'Lồng sắt trừ bì 12kg/lồng',
      ),
      PartnerContact(
        id: 'contact_3',
        name: 'Ghe Lúa Út Mười',
        phone: '0939112233',
        role: 'Thương lái',
        address: 'Chợ Mới, An Giang',
        note: 'Thương lái thu mua lúa OM18',
      ),
    ];
  }

  List<WeighingSession> _createDemoSessions() {
    final now = DateTime.now();
    final riceWeights = [
      51.5, 53.0, 52.5, 54.0, 50.5, // Cột 1
      52.0, 53.5, 51.0, 52.5, 53.0, // Cột 2
      54.5, 52.0, 50.8, 51.2, 53.0, // Cột 3
    ];
    final pigWeights = [
      115.5, 120.0, 118.5, 122.0, 116.0, // Cột 1
      124.5, 119.0, 121.5, // Cột 2
    ];

    return [
      WeighingSession(
        id: 'demo_rice_1',
        title: 'Lúa Đài Thơm 8 - Đồng Cánh Bắc',
        type: SessionType.rice,
        seasonId: 'season_1',
        partnerId: 'contact_1',
        partnerName: 'Chú Bảy Thành',
        partnerPhone: '0918234567',
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        rowsPerColumn: 5,
        entries: List.generate(
          riceWeights.length,
          (i) => WeighingEntry(
            id: 'r_$i',
            weight: riceWeights[i],
            headCount: 1,
            timestamp: now.subtract(Duration(minutes: 60 - i)),
          ),
        ),
        tareMode: TareMode.bagsPerKg,
        tareValue: 8.0, // 8 bao = 1 kg
        roundTareToHalfKg: false,
        impurityPercent: 0.0,
        impurityFixedKg: 2.0, // Trừ tạp chất 2 kg
        pricePerKg: 8600, // 8.600 đ/kg
        depositAmount: 2000000, // Cọc trước 2 triệu
        extraCostAmount: 0,
        isPaid: false,
        note: 'Trừ 8 bao 1 ký, cọc trước 2 triệu đồng.',
      ),
      WeighingSession(
        id: 'demo_pig_1',
        title: 'Xuất Heo Thịt Chuồng A2',
        type: SessionType.pig,
        seasonId: 'season_1',
        partnerId: 'contact_2',
        partnerName: 'Anh Tư Sang',
        partnerPhone: '0909876543',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        rowsPerColumn: 5,
        entries: List.generate(
          pigWeights.length,
          (i) => WeighingEntry(
            id: 'p_$i',
            weight: pigWeights[i],
            headCount: 1, // Mỗi lần cân 1 con
            timestamp: now.subtract(Duration(hours: 24, minutes: 30 - i)),
          ),
        ),
        tareMode: TareMode.kgPerUnit,
        tareValue: 12.0, // Trừ lồng sắt 12 kg / lần cân
        roundTareToHalfKg: false,
        impurityPercent: 0.0,
        impurityFixedKg: 0.0,
        pricePerKg: 65000, // 65.000 đ/kg
        depositAmount: 10000000, // Cọc 10 triệu
        extraCostAmount: 0,
        isPaid: true,
        note: 'Mỗi mã cân 1 con heo trong lồng sắt 12kg.',
      ),
    ];
  }
}
