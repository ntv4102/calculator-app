import 'package:flutter_test/flutter_test.dart';
import 'package:can_lua_heo_pro/models/weighing_models.dart';
import 'package:can_lua_heo_pro/utils/formatters.dart';

void main() {
  group('Kiểm tra logic nhập số cân nhanh & tính toán trừ bì', () {
    test('Nhập nhanh 3 chữ số tự hiểu 1 số lẻ (525 -> 52.5 kg)', () {
      expect(
        AppFormatters.parseFastWeight('525', autoOneDecimal: true),
        equals(52.5),
      );
      expect(
        AppFormatters.parseFastWeight('1185', autoOneDecimal: true),
        equals(118.5),
      );
      expect(
        AppFormatters.parseFastWeight('52.5', autoOneDecimal: false),
        equals(52.5),
      );
    });

    test('Tính trừ bao lúa theo kiểu miền Tây (8 bao = 1 kg) và thành tiền', () {
      final now = DateTime.now();
      final entries = List.generate(
        16,
        (i) => WeighingEntry(id: '$i', weight: 50.0, timestamp: now),
      );

      final session = WeighingSession(
        id: 's1',
        title: 'Lúa OM18',
        type: SessionType.rice,
        seasonId: 'season_1',
        partnerName: 'Chú Bảy',
        createdAt: now,
        updatedAt: now,
        rowsPerColumn: 5,
        entries: entries,
        tareMode: TareMode.bagsPerKg,
        tareValue: 8.0, // 16 bao / 8 = trừ 2 kg bì
        pricePerKg: 8500,
        depositAmount: 1000000,
      );

      expect(session.totalEntriesCount, equals(16));
      expect(session.grossWeight, equals(800.0));
      expect(session.tareWeight, equals(2.0));
      expect(session.netWeight, equals(798.0));
      expect(session.totalAmount, equals(798.0 * 8500));
      expect(session.remainingAmount, equals(798.0 * 8500 - 1000000));
    });

    test('Tính trừ bì lồng heo theo kg/lồng (12 kg/lồng)', () {
      final now = DateTime.now();
      final entries = [
        WeighingEntry(id: '1', weight: 112.0, headCount: 1, timestamp: now),
        WeighingEntry(id: '2', weight: 115.0, headCount: 1, timestamp: now),
      ];

      final session = WeighingSession(
        id: 's2',
        title: 'Heo thịt',
        type: SessionType.pig,
        seasonId: 'season_1',
        partnerName: 'Anh Tư',
        createdAt: now,
        updatedAt: now,
        entries: entries,
        tareMode: TareMode.kgPerUnit,
        tareValue: 12.0, // 2 lồng * 12 = 24 kg
        pricePerKg: 65000,
      );

      expect(session.grossWeight, equals(227.0));
      expect(session.tareWeight, equals(24.0));
      expect(session.netWeight, equals(203.0));
    });
  });
}
