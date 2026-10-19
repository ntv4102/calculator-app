import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');
  static final NumberFormat _weightFormat = NumberFormat('#,##0.##', 'vi_VN');
  static final NumberFormat _weightOneDecimal = NumberFormat('0.0', 'en_US');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateOnlyFormat = DateFormat('dd/MM/yyyy');

  /// Định dạng tiền tệ VNĐ (VD: 15.250.000 đ)
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatted = _currencyFormat.format(amount.round());
    return showSymbol ? '$formatted đ' : formatted;
  }

  /// Định dạng khối lượng kg (VD: 1.250,5 kg)
  static String formatWeight(double weight, {bool showUnit = false}) {
    final formatted = _weightFormat.format(weight);
    return showUnit ? '$formatted kg' : formatted;
  }

  /// Định dạng số cân trong ô bảng (VD: 52.5 hoặc 52)
  static String formatCellWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return _weightOneDecimal.format(weight);
  }

  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateOnlyFormat.format(dt);

  /// Chuyển đổi chuỗi nhập nhanh sang số kg.
  /// Nếu bật [autoOneDecimal]:
  /// - Gõ "525" -> 52.5 kg
  /// - Gõ "1025" -> 102.5 kg
  /// - Nếu người dùng chủ động gõ dấu chấm (VD: "52.5" hoặc "50.") thì giữ nguyên giá trị thực.
  /// - Nếu chỉ gõ 1-2 chữ số (VD: "50") thì giữ nguyên 50.0 kg (hoặc chia 10 nếu > 150).
  static double? parseFastWeight(
    String rawInput, {
    required bool autoOneDecimal,
  }) {
    final cleaned = rawInput.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;

    if (cleaned.contains('.')) {
      return double.tryParse(cleaned);
    }

    final val = double.tryParse(cleaned);
    if (val == null) return null;

    if (autoOneDecimal && cleaned.length >= 3) {
      return val / 10.0;
    }
    return val;
  }

  /// Tạo câu đọc giọng nói tiếng Việt tự nhiên cho mã cân
  static String weightToSpeechText(double weight, {bool isPig = false}) {
    final intPart = weight.floor();
    final decimalPart = ((weight - intPart) * 10).round();

    if (decimalPart == 0) {
      return '$intPart ký';
    } else if (decimalPart == 5 && !isPig) {
      return '$intPart ký rưỡi';
    } else {
      return '$intPart phẩy $decimalPart ký';
    }
  }

  /// Đọc số tiền bằng chữ tiếng Việt (VD: 12.500.000 -> Mười hai triệu năm trăm nghìn đồng)
  static String moneyToVietnameseWords(double amount) {
    final int number = amount.round().abs();
    if (number == 0) return 'Không đồng';

    final List<String> digits = [
      'không',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín'
    ];
    final List<String> units = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ'];

    String readThreeDigits(int n, bool showZeroHundred) {
      int hundred = n ~/ 100;
      int ten = (n % 100) ~/ 10;
      int unit = n % 10;
      List<String> parts = [];

      if (hundred > 0 || showZeroHundred) {
        parts.add('${digits[hundred]} trăm');
      }

      if (ten > 1) {
        parts.add('${digits[ten]} mươi');
        if (unit == 1) {
          parts.add('mốt');
        } else if (unit == 4) {
          parts.add('tư');
        } else if (unit == 5) {
          parts.add('lăm');
        } else if (unit > 0) {
          parts.add(digits[unit]);
        }
      } else if (ten == 1) {
        parts.add('mười');
        if (unit == 5) {
          parts.add('lăm');
        } else if (unit > 0) {
          parts.add(digits[unit]);
        }
      } else if (ten == 0 && unit > 0) {
        if (hundred > 0 || showZeroHundred) {
          parts.add('lẻ');
        }
        parts.add(digits[unit]);
      }

      return parts.join(' ');
    }

    int temp = number;
    List<int> groups = [];
    while (temp > 0) {
      groups.add(temp % 1000);
      temp ~/= 1000;
    }

    List<String> resultParts = [];
    for (int i = groups.length - 1; i >= 0; i--) {
      if (groups[i] > 0) {
        bool showZeroHundred = i < groups.length - 1;
        String groupText = readThreeDigits(groups[i], showZeroHundred);
        if (units[i].isNotEmpty) {
          resultParts.add('$groupText ${units[i]}');
        } else {
          resultParts.add(groupText);
        }
      }
    }

    String sentence = resultParts.join(' ').trim();
    if (sentence.isEmpty) return 'Không đồng';
    sentence = sentence[0].toUpperCase() + sentence.substring(1);
    return '${amount < 0 ? "Âm " : ""}$sentence đồng';
  }
}
