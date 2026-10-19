import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weighing_models.dart';
import '../providers/app_provider.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sessions = provider.filteredSessions;
    final c = AppColors.of(context);

    final pigSessions =
        sessions.where((s) => s.type == SessionType.pig).toList();

    final totalPigHeads =
        pigSessions.fold(0, (sum, s) => sum + s.totalHeadCount);
    final totalPigNetKg =
        pigSessions.fold(0.0, (sum, s) => sum + s.netWeight);
    final totalPigMoney =
        pigSessions.fold(0.0, (sum, s) => sum + s.totalAmount);
    final avgPigWeight =
        totalPigHeads > 0 ? totalPigNetKg / totalPigHeads : 0.0;

    final totalDeposit =
        pigSessions.fold(0.0, (sum, s) => sum + s.depositAmount);
    final totalUnpaid = pigSessions
        .where((s) => !s.isPaid)
        .fold(0.0, (sum, s) => sum + s.remainingAmount);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        title: const Text('Thống Kê Sản Lượng Heo'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            // Tổng quan tài chính
            Container(
              padding: const EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: c.accentPig, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TỔNG GIÁ TRỊ GIAO DỊCH HEO (${pigSessions.length} PHIẾU)',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    AppFormatters.formatCurrency(totalPigMoney),
                    style: AppTokens.numericTitle(c.accentPig),
                  ),
                  Divider(color: c.border, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatMetric(
                        label: 'Đã đặt cọc trước',
                        value: AppFormatters.formatCurrency(totalDeposit),
                        valueColor: c.text,
                        mutedColor: c.textMuted,
                      ),
                      _buildStatMetric(
                        label: 'Còn nợ chưa tất toán',
                        value: AppFormatters.formatCurrency(totalUnpaid),
                        valueColor: totalUnpaid > 0 ? c.warning : c.success,
                        mutedColor: c.textMuted,
                        alignRight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // Thống kê Cân Heo
            _buildCategoryStatBlock(
              c: c,
              title: 'SẢN LƯỢNG HEO / GIA SÚC',
              icon: Icons.pets_rounded,
              accentColor: c.accentPig,
              accentSoft: c.accentPigSoft,
              sessionCount: pigSessions.length,
              unitCountLabel: 'Tổng đàn heo đã cân:',
              unitCountValue: '$totalPigHeads con',
              netWeightKg: totalPigNetKg,
              avgWeightKg: avgPigWeight,
              totalMoney: totalPigMoney,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric({
    required String label,
    required String value,
    required Color valueColor,
    required Color mutedColor,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTokens.numericMetric(valueColor),
        ),
      ],
    );
  }

  Widget _buildCategoryStatBlock({
    required AppColors c,
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color accentSoft,
    required int sessionCount,
    required String unitCountLabel,
    required String unitCountValue,
    required double netWeightKg,
    required double totalMoney,
    double? avgWeightKg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'Số phiếu cân: $sessionCount phiếu',
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 22, color: c.border),
          _buildRow(unitCountLabel, unitCountValue, c: c),
          _buildRow(
            'Tổng khối lượng tịnh:',
            AppFormatters.formatWeight(netWeightKg, showUnit: true),
            c: c,
          ),
          if (avgWeightKg != null)
            _buildRow(
              'Trọng lượng trung bình:',
              '${AppFormatters.formatWeight(avgWeightKg, showUnit: true)} / con',
              c: c,
            ),
          _buildRow(
            'Tổng thành tiền:',
            AppFormatters.formatCurrency(totalMoney),
            c: c,
            isBold: true,
            valueColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    required AppColors c,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: c.textMuted),
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

  Future<void> _showAddSeasonDialog(
    BuildContext context,
    AppProvider provider,
  ) async {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final noteFocus = FocusNode();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Mùa Vụ / Đợt Cân Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => noteFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Tên mùa vụ (VD: Vụ Đông Xuân 2027)',
              ),
            ),
            const SizedBox(height: AppTokens.space12),
            TextField(
              controller: noteCtrl,
              focusNode: noteFocus,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tuỳ chọn)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppTokens.minTouchTarget,
                AppTokens.minTouchTarget,
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(
                AppTokens.minTouchTarget,
                AppTokens.minTouchTarget,
              ),
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await provider.addSeason(nameCtrl.text, note: noteCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Lưu Mùa Vụ'),
          ),
        ],
      ),
    );
  }
}
