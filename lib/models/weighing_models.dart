import 'dart:math' as math;

enum SessionType {
  rice, // Cân lúa / nông sản
  pig, // Cân heo / gia súc
}

extension SessionTypeExt on SessionType {
  String get label =>
      this == SessionType.rice ? 'Cân Lúa / Nông Sản' : 'Cân Heo / Gia Súc';
  String get shortLabel => this == SessionType.rice ? 'Cân Lúa' : 'Cân Heo';
  String get unitName => this == SessionType.rice ? 'bao' : 'mã cân';
  String get subUnitName => this == SessionType.rice ? 'bao' : 'con';
}

/// Chế độ trừ bì (trừ bao lúa hoặc trừ lồng heo)
enum TareMode {
  bagsPerKg, // Kiểu miền Tây: X bao = 1 kg (VD: 7 bao = 1 kg, 8 bao = 1 kg)
  kgPerUnit, // Trừ X kg trên mỗi mã cân / mỗi bao / mỗi lồng (VD: 12 kg/lồng)
  fixedTotalKg, // Nhập trực tiếp tổng số kg bì cần trừ
}

extension TareModeExt on TareMode {
  String get label {
    switch (this) {
      case TareMode.bagsPerKg:
        return 'Theo quy tắc: X bao = 1 kg (Miền Tây)';
      case TareMode.kgPerUnit:
        return 'Trừ số kg trên mỗi bao / mỗi lồng';
      case TareMode.fixedTotalKg:
        return 'Nhập tổng số kg bì trực tiếp';
    }
  }
}

/// Một mã cân đơn lẻ trong bảng
class WeighingEntry {
  final String id;
  final double weight; // Khối lượng (kg)
  final int headCount; // Số con heo trong lồng (nếu cân lúa thì mặc định = 1 bao)
  final DateTime timestamp;
  final String note;

  WeighingEntry({
    required this.id,
    required this.weight,
    this.headCount = 1,
    required this.timestamp,
    this.note = '',
  });

  WeighingEntry copyWith({
    double? weight,
    int? headCount,
    String? note,
  }) {
    return WeighingEntry(
      id: id,
      weight: weight ?? this.weight,
      headCount: headCount ?? this.headCount,
      timestamp: timestamp,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'headCount': headCount,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory WeighingEntry.fromJson(Map<String, dynamic> json) => WeighingEntry(
        id: json['id'] as String,
        weight: (json['weight'] as num).toDouble(),
        headCount: (json['headCount'] as num?)?.toInt() ?? 1,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        note: json['note'] as String? ?? '',
      );
}

/// Một phiếu cân hoàn chỉnh
class WeighingSession {
  final String id;
  final String title; // Tên phiếu hoặc tên giống lúa / đàn heo (VD: OM18, Đài Thơm 8, Heo thịt...)
  final SessionType type;
  final String seasonId; // Thuộc mùa vụ / đợt nào
  final String partnerId; // ID thương lái / nông dân (nếu có)
  final String partnerName; // Tên nông dân / thương lái
  final String partnerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Số dòng trên mỗi cột (thường là 5 hoặc 10 mã cân / cột)
  final int rowsPerColumn;

  /// Danh sách các mã cân theo thứ tự nhập
  final List<WeighingEntry> entries;

  /// Cấu hình trừ bì
  final TareMode tareMode;
  final double tareValue; // Nếu bagsPerKg: số bao/1kg (VD 7, 8). Nếu kgPerUnit: số kg/lồng. Nếu fixedTotalKg: tổng kg bì.
  final bool roundTareToHalfKg; // Tuỳ chọn làm tròn số kg trừ bao

  /// Trừ tạp chất / độ ẩm / hao hụt (tính bằng kg hoặc %)
  final double impurityPercent; // % trừ độ ẩm/tạp chất
  final double impurityFixedKg; // Số kg trừ thêm trực tiếp

  /// Đơn giá & Thanh toán
  final double pricePerKg; // Đơn giá (VNĐ / kg)
  final double depositAmount; // Tiền đặt cọc trước (VNĐ)
  final double extraCostAmount; // Chi phí phụ trừ thêm (tiền vác, tiền xe...)
  final bool isPaid; // Đã tất toán hay còn nợ
  final String note;

  WeighingSession({
    required this.id,
    required this.title,
    required this.type,
    required this.seasonId,
    this.partnerId = '',
    required this.partnerName,
    this.partnerPhone = '',
    required this.createdAt,
    required this.updatedAt,
    this.rowsPerColumn = 5,
    required this.entries,
    required this.tareMode,
    required this.tareValue,
    this.roundTareToHalfKg = false,
    this.impurityPercent = 0,
    this.impurityFixedKg = 0,
    required this.pricePerKg,
    this.depositAmount = 0,
    this.extraCostAmount = 0,
    this.isPaid = false,
    this.note = '',
  });

  /// Tổng số lần cân (số bao lúa hoặc số lượt cân heo)
  int get totalEntriesCount => entries.length;

  /// Tổng số con (hữu ích khi cân heo nhiều con 1 lồng; với lúa thì bằng số bao)
  int get totalHeadCount =>
      entries.fold(0, (sum, item) => sum + item.headCount);

  /// Tổng khối lượng thô chưa trừ bì (Gross Weight - kg)
  double get grossWeight =>
      entries.fold(0.0, (sum, item) => sum + item.weight);

  /// Khối lượng trung bình mỗi bao / mỗi con
  double get averageWeight {
    if (type == SessionType.pig) {
      return totalHeadCount > 0 ? netWeight / totalHeadCount : 0.0;
    }
    return totalEntriesCount > 0 ? grossWeight / totalEntriesCount : 0.0;
  }

  /// Số cột hiện tại
  int get columnCount {
    if (entries.isEmpty) return 1;
    return (entries.length / rowsPerColumn).ceil();
  }

  /// Lấy danh sách mã cân của cột thứ [colIndex] (0-based)
  List<WeighingEntry> getColumnEntries(int colIndex) {
    final start = colIndex * rowsPerColumn;
    if (start >= entries.length) return [];
    final end = math.min(start + rowsPerColumn, entries.length);
    return entries.sublist(start, end);
  }

  /// Tổng khối lượng của cột thứ [colIndex]
  double getColumnSubtotal(int colIndex) {
    return getColumnEntries(colIndex)
        .fold(0.0, (sum, item) => sum + item.weight);
  }

  /// Số kg trừ bì (Tare Weight)
  double get tareWeight {
    if (entries.isEmpty || tareValue <= 0) return 0.0;
    double rawTare = 0.0;
    switch (tareMode) {
      case TareMode.bagsPerKg:
        // VD: 8 bao = 1 kg -> Tổng số bao / 8
        rawTare = totalEntriesCount / tareValue;
        break;
      case TareMode.kgPerUnit:
        // VD: Mỗi lồng heo trừ 12 kg -> Số lượt cân * 12
        rawTare = totalEntriesCount * tareValue;
        break;
      case TareMode.fixedTotalKg:
        rawTare = tareValue;
        break;
    }
    if (roundTareToHalfKg) {
      return (rawTare * 2).round() / 2.0;
    }
    // Làm tròn 2 chữ số thập phân để dễ tính
    return (rawTare * 100).round() / 100.0;
  }

  /// Khối lượng sau khi trừ bì
  double get weightAfterTare => math.max(0.0, grossWeight - tareWeight);

  /// Số kg trừ tạp chất / độ ẩm
  double get impurityWeight {
    final byPercent = weightAfterTare * (impurityPercent / 100.0);
    final totalImpurity = byPercent + impurityFixedKg;
    return (totalImpurity * 100).round() / 100.0;
  }

  /// Khối lượng thực tế tính tiền (Net Weight - kg)
  double get netWeight =>
      math.max(0.0, weightAfterTare - impurityWeight);

  /// Tổng thành tiền trước khi trừ cọc (VNĐ)
  double get totalAmount => netWeight * pricePerKg;

  /// Số tiền còn lại phải thanh toán sau khi trừ tiền cọc và chi phí phụ
  double get remainingAmount =>
      totalAmount - depositAmount - extraCostAmount;

  WeighingSession copyWith({
    String? title,
    SessionType? type,
    String? seasonId,
    String? partnerId,
    String? partnerName,
    String? partnerPhone,
    DateTime? updatedAt,
    int? rowsPerColumn,
    List<WeighingEntry>? entries,
    TareMode? tareMode,
    double? tareValue,
    bool? roundTareToHalfKg,
    double? impurityPercent,
    double? impurityFixedKg,
    double? pricePerKg,
    double? depositAmount,
    double? extraCostAmount,
    bool? isPaid,
    String? note,
  }) {
    return WeighingSession(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      seasonId: seasonId ?? this.seasonId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      rowsPerColumn: rowsPerColumn ?? this.rowsPerColumn,
      entries: entries ?? this.entries,
      tareMode: tareMode ?? this.tareMode,
      tareValue: tareValue ?? this.tareValue,
      roundTareToHalfKg: roundTareToHalfKg ?? this.roundTareToHalfKg,
      impurityPercent: impurityPercent ?? this.impurityPercent,
      impurityFixedKg: impurityFixedKg ?? this.impurityFixedKg,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      depositAmount: depositAmount ?? this.depositAmount,
      extraCostAmount: extraCostAmount ?? this.extraCostAmount,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'seasonId': seasonId,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'partnerPhone': partnerPhone,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'rowsPerColumn': rowsPerColumn,
        'entries': entries.map((e) => e.toJson()).toList(),
        'tareMode': tareMode.name,
        'tareValue': tareValue,
        'roundTareToHalfKg': roundTareToHalfKg,
        'impurityPercent': impurityPercent,
        'impurityFixedKg': impurityFixedKg,
        'pricePerKg': pricePerKg,
        'depositAmount': depositAmount,
        'extraCostAmount': extraCostAmount,
        'isPaid': isPaid,
        'note': note,
      };

  factory WeighingSession.fromJson(Map<String, dynamic> json) {
    return WeighingSession(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Phiếu cân',
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.rice,
      ),
      seasonId: json['seasonId'] as String? ?? 'default',
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? 'Khách lẻ',
      partnerPhone: json['partnerPhone'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      rowsPerColumn: (json['rowsPerColumn'] as num?)?.toInt() ?? 5,
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((e) => WeighingEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      tareMode: TareMode.values.firstWhere(
        (e) => e.name == json['tareMode'],
        orElse: () => TareMode.bagsPerKg,
      ),
      tareValue: (json['tareValue'] as num?)?.toDouble() ?? 8.0,
      roundTareToHalfKg: json['roundTareToHalfKg'] as bool? ?? false,
      impurityPercent: (json['impurityPercent'] as num?)?.toDouble() ?? 0.0,
      impurityFixedKg: (json['impurityFixedKg'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      extraCostAmount: (json['extraCostAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] as bool? ?? false,
      note: json['note'] as String? ?? '',
    );
  }
}

/// Thông tin Nông dân / Thương lái
class PartnerContact {
  final String id;
  final String name;
  final String phone;
  final String role; // 'Nông dân', 'Thương lái', 'Chủ trại'
  final String address;
  final String note;

  PartnerContact({
    required this.id,
    required this.name,
    this.phone = '',
    this.role = 'Nông dân',
    this.address = '',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'address': address,
        'note': note,
      };

  factory PartnerContact.fromJson(Map<String, dynamic> json) => PartnerContact(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'Nông dân',
        address: json['address'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );
}

/// Mùa vụ / Đợt cân
class SeasonBatch {
  final String id;
  final String name; // VD: "Vụ Đông Xuân 2026", "Đợt xuất heo Tháng 10"
  final DateTime createdAt;
  final String note;

  SeasonBatch({
    required this.id,
    required this.name,
    required this.createdAt,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory SeasonBatch.fromJson(Map<String, dynamic> json) => SeasonBatch(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Mùa vụ mới',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        note: json['note'] as String? ?? '',
      );
}
