import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/weighing_models.dart';
import '../utils/formatters.dart';

class ExportService {
  /// Tạo nội dung văn bản chi tiết để gửi nhanh qua Zalo / Tin nhắn
  static String buildTextReceipt(WeighingSession session) {
    final sb = StringBuffer();
    sb.writeln('📋 PHIẾU ${session.type.label.toUpperCase()}');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('📌 Phiếu: ${session.title}');
    sb.writeln('👤 Khách hàng: ${session.partnerName}'
        '${session.partnerPhone.isNotEmpty ? " (${session.partnerPhone})" : ""}');
    sb.writeln('🕒 Thời gian: ${AppFormatters.formatDateTime(session.createdAt)}');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');

    for (int col = 0; col < session.columnCount; col++) {
      final colEntries = session.getColumnEntries(col);
      if (colEntries.isEmpty) continue;
      final weightsStr = colEntries
          .map((e) => AppFormatters.formatCellWeight(e.weight))
          .join(' + ');
      final colSum = session.getColumnSubtotal(col);
      sb.writeln('Cột ${col + 1}: $weightsStr');
      sb.writeln('           = ${AppFormatters.formatWeight(colSum, showUnit: true)}');
    }

    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    if (session.type == SessionType.pig) {
      sb.writeln(
          '🐷 Tổng số lượt cân: ${session.totalEntriesCount} lượt (${session.totalHeadCount} con)');
    } else {
      sb.writeln('🌾 Tổng số bao: ${session.totalEntriesCount} bao');
    }
    sb.writeln(
        '⚖️ Tổng cân thô: ${AppFormatters.formatWeight(session.grossWeight, showUnit: true)}');
    sb.writeln(
        '➖ Trừ bì (${_describeTare(session)}): -${AppFormatters.formatWeight(session.tareWeight, showUnit: true)}');
    if (session.impurityWeight > 0) {
      sb.writeln(
          '➖ Trừ tạp chất/độ ẩm: -${AppFormatters.formatWeight(session.impurityWeight, showUnit: true)}');
    }
    sb.writeln(
        '✅ SAU KHI TRỪ BÌ: ${AppFormatters.formatWeight(session.netWeight, showUnit: true)}');
    sb.writeln(
        session.type == SessionType.rice
            ? '📊 Bình quân 1 bao: ${AppFormatters.formatWeight(session.averageWeight, showUnit: true)}/bao'
            : '🐷 Bình quân 1 con heo: ${AppFormatters.formatWeight(session.averageWeight, showUnit: true)}/con');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln(
        '💵 Đơn giá: ${AppFormatters.formatCurrency(session.pricePerKg)}/kg');
    sb.writeln(
        '💰 Thành tiền: ${AppFormatters.formatCurrency(session.totalAmount)}');
    if (session.depositAmount > 0) {
      sb.writeln(
          '💳 Đã đặt cọc: -${AppFormatters.formatCurrency(session.depositAmount)}');
    }
    if (session.extraCostAmount > 0) {
      sb.writeln(
          '🚛 Trừ chi phí phụ: -${AppFormatters.formatCurrency(session.extraCostAmount)}');
    }
    sb.writeln(
        '👉 TỔNG TIỀN: ${AppFormatters.formatCurrency(session.remainingAmount)}');
    sb.writeln(
        '(${AppFormatters.moneyToVietnameseWords(session.remainingAmount)})');
    if (session.note.isNotEmpty) {
      sb.writeln('📝 Ghi chú: ${session.note}');
    }
    return sb.toString();
  }

  static String _describeTare(WeighingSession s) {
    switch (s.tareMode) {
      case TareMode.bagsPerKg:
        return '${AppFormatters.formatWeight(s.tareValue)} bao = 1kg';
      case TareMode.kgPerUnit:
        return '${AppFormatters.formatWeight(s.tareValue)} kg/${s.type.unitName}';
      case TareMode.fixedTotalKg:
        return 'Trừ cố định';
    }
  }

  /// Chia sẻ phiếu cân qua Zalo / Messenger / SMS
  static Future<void> shareSessionText(WeighingSession session) async {
    final text = buildTextReceipt(session);
    await Share.share(text, subject: 'Phiếu cân - ${session.title}');
  }

  /// Xuất PDF & Mở hộp thoại In / Lưu PDF (hỗ trợ cả khổ A4 và máy in nhiệt 80mm)
  static Future<void> printOrExportPdf(
    WeighingSession session, {
    bool isThermalRoll = false,
  }) async {
    final doc = pw.Document();
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final pageFormat = isThermalRoll ? PdfPageFormat.roll80 : PdfPageFormat.a4;

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: isThermalRoll
            ? const pw.EdgeInsets.all(10)
            : const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(font: fontRegular, fontSize: isThermalRoll ? 9 : 11),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'PHIẾU ${session.type.label.toUpperCase()}',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: isThermalRoll ? 13 : 18,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    session.title,
                    style: pw.TextStyle(font: fontBold, fontSize: isThermalRoll ? 10 : 13),
                  ),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Khách hàng: ${session.partnerName}'),
                    if (session.partnerPhone.isNotEmpty)
                      pw.Text('SĐT: ${session.partnerPhone}'),
                  ],
                ),
                pw.Text('Ngày cân: ${AppFormatters.formatDateTime(session.createdAt)}'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'BẢNG CHI TIẾT MÃ CÂN (kg):',
                  style: pw.TextStyle(font: fontBold),
                ),
                pw.SizedBox(height: 6),
                _buildColumnsGridPdf(session, fontRegular, fontBold),
                pw.SizedBox(height: 10),
                pw.Divider(),
                _buildSummaryRowPdf(
                  session.type == SessionType.pig
                      ? 'Tổng số lượt cân (${session.totalHeadCount} con):'
                      : 'Tổng số bao:',
                  '${session.totalEntriesCount} ${session.type.unitName}',
                  fontRegular,
                  fontBold,
                ),
                _buildSummaryRowPdf(
                  'Tổng khối lượng thô (Chưa trừ bì):',
                  AppFormatters.formatWeight(session.grossWeight, showUnit: true),
                  fontRegular,
                  fontBold,
                ),
                _buildSummaryRowPdf(
                  'Trừ bì (${_describeTare(session)}):',
                  '-${AppFormatters.formatWeight(session.tareWeight, showUnit: true)}',
                  fontRegular,
                  fontBold,
                ),
                if (session.impurityWeight > 0)
                  _buildSummaryRowPdf(
                    'Trừ tạp chất / độ ẩm:',
                    '-${AppFormatters.formatWeight(session.impurityWeight, showUnit: true)}',
                    fontRegular,
                    fontBold,
                  ),
                _buildSummaryRowPdf(
                  'SAU KHI TRỪ BÌ:',
                  AppFormatters.formatWeight(session.netWeight, showUnit: true),
                  fontBold,
                  fontBold,
                ),
                pw.Divider(),
                _buildSummaryRowPdf(
                  'Đơn giá:',
                  '${AppFormatters.formatCurrency(session.pricePerKg)} / kg',
                  fontRegular,
                  fontBold,
                ),
                _buildSummaryRowPdf(
                  'Thành tiền:',
                  AppFormatters.formatCurrency(session.totalAmount),
                  fontRegular,
                  fontBold,
                ),
                if (session.depositAmount > 0)
                  _buildSummaryRowPdf(
                    'Trừ tiền cọc trước:',
                    '-${AppFormatters.formatCurrency(session.depositAmount)}',
                    fontRegular,
                    fontBold,
                  ),
                if (session.extraCostAmount > 0)
                  _buildSummaryRowPdf(
                    'Chi phí phụ (bốc vác/xe):',
                    '-${AppFormatters.formatCurrency(session.extraCostAmount)}',
                    fontRegular,
                    fontBold,
                  ),
                pw.SizedBox(height: 4),
                _buildSummaryRowPdf(
                  'TỔNG TIỀN:',
                  AppFormatters.formatCurrency(session.remainingAmount),
                  fontBold,
                  fontBold,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Bằng chữ: ${AppFormatters.moneyToVietnameseWords(session.remainingAmount)}',
                  style: pw.TextStyle(font: fontItalic, fontSize: 10),
                ),
                if (session.note.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text('Ghi chú: ${session.note}'),
                ],
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Phieu_Can_${session.id}.pdf',
    );
  }

  static pw.Widget _buildColumnsGridPdf(
    WeighingSession session,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    final int totalCols = session.columnCount;
    final int maxColsPerTable = 5;
    final List<pw.Widget> tables = [];

    for (int startCol = 0; startCol < totalCols; startCol += maxColsPerTable) {
      final int endCol = (startCol + maxColsPerTable < totalCols)
          ? startCol + maxColsPerTable
          : totalCols;
      final int colsInBatch = endCol - startCol;

      final headers = List.generate(
        colsInBatch,
        (i) => pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Center(
            child: pw.Text(
              'Cột ${startCol + i + 1}',
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
          ),
        ),
      );

      final List<pw.TableRow> rows = [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers,
        ),
      ];

      for (int r = 0; r < session.rowsPerColumn; r++) {
        rows.add(
          pw.TableRow(
            children: List.generate(colsInBatch, (c) {
              final colIndex = startCol + c;
              final entries = session.getColumnEntries(colIndex);
              final text = r < entries.length
                  ? AppFormatters.formatCellWeight(entries[r].weight)
                  : '-';
              return pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Text(text, style: pw.TextStyle(font: fontRegular)),
                ),
              );
            }),
          ),
        );
      }

      // Row tổng cột
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.amber50),
          children: List.generate(colsInBatch, (c) {
            final colIndex = startCol + c;
            final sum = session.getColumnSubtotal(colIndex);
            return pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Center(
                child: pw.Text(
                  AppFormatters.formatCellWeight(sum),
                  style: pw.TextStyle(font: fontBold),
                ),
              ),
            );
          }),
        ),
      );

      tables.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
            children: rows,
          ),
        ),
      );
    }

    return pw.Column(children: tables);
  }

  static pw.Widget _buildSummaryRowPdf(
    String label,
    String value,
    pw.Font labelFont,
    pw.Font valueFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.AxisAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: labelFont)),
          pw.Text(value, style: pw.TextStyle(font: valueFont)),
        ],
      ),
    );
  }
}
