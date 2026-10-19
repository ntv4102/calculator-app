import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/weighing_models.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final String sessionId;

  const ReceiptPreviewScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final session = provider.getSessionById(sessionId);
    final c = AppColors.of(context);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phiếu cân')),
        body: const Center(child: Text('Không tìm thấy phiếu cân')),
      );
    }

    final isRice = session.type == SessionType.rice;
    final accentColor = isRice ? c.accentRice : c.accentPig;
    final accentSoft = isRice ? c.accentRiceSoft : c.accentPigSoft;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        title: const Text('Phiếu Cân & Thanh Toán'),
        leading: IconButton(
          tooltip: 'Quay về trang chủ',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Sao chép nội dung phiếu cân vào bộ nhớ tạm',
            child: IconButton(
              constraints: const BoxConstraints(
                minWidth: AppTokens.minTouchTarget,
                minHeight: AppTokens.minTouchTarget,
              ),
              tooltip: 'Sao chép văn bản',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                final text = ExportService.buildTextReceipt(session);
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép phiếu cân! Mở Zalo và dán để gửi.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            Container(
              padding: const EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: c.borderStrong),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.space12,
                            vertical: AppTokens.space4,
                          ),
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSm),
                          ),
                          child: Text(
                            'PHIẾU ${session.type.label.toUpperCase()}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space8),
                        Text(
                          session.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          'Ngày cân: ${AppFormatters.formatDateTime(session.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: c.textMuted,
                            fontFeatures: AppTokens.tabularNums,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 24, color: c.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Khách hàng: ${session.partnerName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: c.text,
                          ),
                        ),
                      ),
                      if (session.partnerPhone.isNotEmpty)
                        Text(
                          'SĐT: ${session.partnerPhone}',
                          style: TextStyle(
                            fontSize: 13,
                            color: c.textMuted,
                            fontFeatures: AppTokens.tabularNums,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space12),
                  Text(
                    'BẢNG KÊ MÃ CÂN THEO CỘT (kg):',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  _buildColumnsBreakdown(session, c, accentColor),
                  Divider(height: 24, color: c.border),
                  _buildReceiptRow(
                    isRice
                        ? 'Tổng số bao lúa:'
                        : 'Tổng số lượt cân (${session.totalHeadCount} con):',
                    '${session.totalEntriesCount} ${session.type.unitName}',
                    c: c,
                  ),
                  _buildReceiptRow(
                    'Tổng cân thô (Chưa trừ bì):',
                    AppFormatters.formatWeight(session.grossWeight,
                        showUnit: true),
                    c: c,
                    isBold: true,
                  ),
                  _buildReceiptRow(
                    'Trừ bì:',
                    '- ${AppFormatters.formatWeight(session.tareWeight, showUnit: true)}',
                    c: c,
                    valueColor: c.danger,
                  ),
                  if (session.impurityWeight > 0)
                    _buildReceiptRow(
                      'Trừ tạp chất / độ ẩm:',
                      '- ${AppFormatters.formatWeight(session.impurityWeight, showUnit: true)}',
                      c: c,
                      valueColor: c.danger,
                    ),
                  _buildReceiptRow(
                    'SAU KHI TRỪ BÌ:',
                    AppFormatters.formatWeight(session.netWeight,
                        showUnit: true),
                    c: c,
                    isBold: true,
                    valueColor: accentColor,
                  ),
                  _buildReceiptRow(
                    isRice ? 'Bình quân 1 bao:' : 'Bình quân 1 con heo:',
                    '${AppFormatters.formatWeight(session.averageWeight, showUnit: true)} / ${session.type.subUnitName}',
                    c: c,
                    isBold: true,
                  ),
                  Divider(height: 24, color: c.border),
                  _buildReceiptRow(
                    'Đơn giá:',
                    '${AppFormatters.formatCurrency(session.pricePerKg)} / kg',
                    c: c,
                  ),
                  _buildReceiptRow(
                    'Thành tiền:',
                    AppFormatters.formatCurrency(session.totalAmount),
                    c: c,
                    isBold: true,
                  ),
                  if (session.depositAmount > 0)
                    _buildReceiptRow(
                      'Trừ tiền đặt cọc:',
                      '- ${AppFormatters.formatCurrency(session.depositAmount)}',
                      c: c,
                      valueColor: c.danger,
                    ),
                  if (session.extraCostAmount > 0)
                    _buildReceiptRow(
                      'Chi phí phụ:',
                      '- ${AppFormatters.formatCurrency(session.extraCostAmount)}',
                      c: c,
                      valueColor: c.danger,
                    ),
                  const SizedBox(height: AppTokens.space12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTokens.space12),
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TỔNG TIỀN:',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: c.text,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(
                                  session.remainingAmount),
                              style: AppTokens.numericTitle(accentColor)
                                  .copyWith(fontSize: 19),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bằng chữ: ${AppFormatters.moneyToVietnameseWords(session.remainingAmount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (session.note.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.space12),
                    Text(
                      'Ghi chú: ${session.note}',
                      style: TextStyle(fontSize: 13, color: c.text),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            // Các nút hành động >= 48dp
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: c.onAccent,
                minimumSize: const Size(
                  double.infinity,
                  AppTokens.minTouchTarget,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'GỬI PHIẾU CÂN QUA ZALO / TIN NHẮN',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              onPressed: () => ExportService.shareSessionText(session),
            ),
            const SizedBox(height: AppTokens.space12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        AppTokens.minTouchTarget,
                      ),
                      side: BorderSide(color: c.borderStrong),
                      foregroundColor: c.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text(
                      'Xuất PDF (A4)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => ExportService.printOrExportPdf(
                      session,
                      isThermalRoll: false,
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        AppTokens.minTouchTarget,
                      ),
                      side: BorderSide(color: c.borderStrong),
                      foregroundColor: c.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text(
                      'In Nhiệt 80mm',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => ExportService.printOrExportPdf(
                      session,
                      isThermalRoll: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnsBreakdown(
    WeighingSession session,
    AppColors c,
    Color accentColor,
  ) {
    if (session.entries.isEmpty) {
      return Text(
        'Chưa có mã cân nào.',
        style: TextStyle(fontStyle: FontStyle.italic, color: c.textMuted),
      );
    }

    return Column(
      children: List.generate(session.columnCount, (colIndex) {
        final entries = session.getColumnEntries(colIndex);
        final subtotal = session.getColumnSubtotal(colIndex);
        final weightsText = entries
            .map((e) => AppFormatters.formatCellWeight(e.weight))
            .join(' + ');

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space12,
            vertical: AppTokens.space8,
          ),
          decoration: BoxDecoration(
            color: c.surfaceSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Cột ${colIndex + 1}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: c.text,
                      ),
                    ),
                    Text(
                      weightsText,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: c.text,
                        fontFeatures: AppTokens.tabularNums,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '= ${AppFormatters.formatCellWeight(subtotal)} kg',
                  style: AppTokens.numericMetric(accentColor).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    required AppColors c,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isBold ? c.text : c.textMuted,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? c.text,
              fontFeatures: AppTokens.tabularNums,
            ),
          ),
        ],
      ),
    );
  }
}
