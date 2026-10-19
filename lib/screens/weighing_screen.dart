import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/weighing_models.dart';
import '../providers/app_provider.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';
import 'receipt_preview_screen.dart';

class WeighingScreen extends StatefulWidget {
  final String sessionId;

  const WeighingScreen({super.key, required this.sessionId});

  @override
  State<WeighingScreen> createState() => _WeighingScreenState();
}

class _WeighingScreenState extends State<WeighingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _horizontalScrollController = ScrollController();

  String _rawInput = '';
  int _pigHeadCountInput = 1;

  late TextEditingController _tareValueCtrl;
  late TextEditingController _impurityPercentCtrl;
  late TextEditingController _impurityKgCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _depositCtrl;
  late TextEditingController _extraCostCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final session =
        context.read<AppProvider>().getSessionById(widget.sessionId);

    _tareValueCtrl = TextEditingController(
      text: session != null
          ? AppFormatters.formatCellWeight(session.tareValue)
          : '8',
    );
    _impurityPercentCtrl = TextEditingController(
      text: session != null && session.impurityPercent > 0
          ? session.impurityPercent.toString()
          : '',
    );
    _impurityKgCtrl = TextEditingController(
      text: session != null && session.impurityFixedKg > 0
          ? session.impurityFixedKg.toString()
          : '',
    );
    _priceCtrl = TextEditingController(
      text: session != null && session.pricePerKg > 0
          ? session.pricePerKg.round().toString()
          : '',
    );
    _depositCtrl = TextEditingController(
      text: session != null && session.depositAmount > 0
          ? session.depositAmount.round().toString()
          : '',
    );
    _extraCostCtrl = TextEditingController(
      text: session != null && session.extraCostAmount > 0
          ? session.extraCostAmount.round().toString()
          : '',
    );
    _noteCtrl = TextEditingController(text: session?.note ?? '');

    // Tự động cuộn sang cột đang nhập (Cột 3 trở lên) để tránh bị khuất UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null &&
          session.columnCount >= 3 &&
          _horizontalScrollController.hasClients) {
        _horizontalScrollController.animateTo(
          _horizontalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _horizontalScrollController.dispose();
    _tareValueCtrl.dispose();
    _impurityPercentCtrl.dispose();
    _impurityKgCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _extraCostCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    HapticFeedback.selectionClick();

    // Tự động cuộn sang cột đang nhập ngay khi người dùng bấm phím số
    final session = context.read<AppProvider>().getSession(widget.sessionId);
    if (session != null &&
        session.columnCount >= 3 &&
        _horizontalScrollController.hasClients) {
      _horizontalScrollController.animateTo(
        _horizontalScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }

    setState(() {
      if (key == 'C') {
        _rawInput = '';
      } else if (key == 'BACK') {
        if (_rawInput.isNotEmpty) {
          _rawInput = _rawInput.substring(0, _rawInput.length - 1);
        }
      } else if (key == '.') {
        if (!_rawInput.contains('.')) {
          _rawInput = _rawInput.isEmpty ? '0.' : '$_rawInput.';
        }
      } else {
        if (_rawInput.length < 6) {
          _rawInput += key;
        }
      }
    });
  }

  Future<void> _submitWeight(
    AppProvider provider,
    WeighingSession session,
  ) async {
    final parsed = AppFormatters.parseFastWeight(
      _rawInput,
      autoOneDecimal: provider.autoOneDecimal,
    );

    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhập số cân lớn hơn 0 kg trước khi bấm Lưu'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _rawInput = '';
    });

    await provider.addWeighingEntry(
      session.id,
      weight: parsed,
      headCount: session.type == SessionType.pig ? _pigHeadCountInput : 1,
    );

    // Tự động cuộn ngang tới cột đang nhập, tôn trọng cài đặt Reduce Motion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalScrollController.hasClients) {
        final target = _horizontalScrollController.position.maxScrollExtent;
        if (disableAnimations) {
          _horizontalScrollController.jumpTo(target);
        } else {
          _horizontalScrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final session = provider.getSessionById(widget.sessionId);
    final c = AppColors.of(context);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Không tìm thấy phiếu cân')),
        body: const Center(child: Text('Phiếu cân này đã bị xoá.')),
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
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            Text(
              'Khách: ${session.partnerName}',
              style: TextStyle(fontSize: 12, color: c.textMuted),
            ),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Xem phiếu cân và gửi qua Zalo hoặc in',
            child: IconButton(
              constraints: const BoxConstraints(
                minWidth: AppTokens.minTouchTarget,
                minHeight: AppTokens.minTouchTarget,
              ),
              icon: const Icon(Icons.receipt_long_rounded),
              tooltip: 'Xem & Xuất phiếu cân',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptPreviewScreen(sessionId: session.id),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelColor: accentColor,
          unselectedLabelColor: c.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: '1. BẢNG CÂN NHANH'),
            Tab(text: '2. TRỪ BÌ & TÍNH TIỀN'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFastWeighingTab(
                provider, session, c, accentColor, accentSoft),
            _buildCalculationTab(
                provider, session, c, accentColor, accentSoft),
          ],
        ),
      ),
    );
  }

  /// Thanh chỉ số thực tế dùng Tabular Figures, không nhảy chữ khi cộng dồn
  Widget _buildTopSummaryStrip(
    WeighingSession session,
    AppColors c,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          _buildBannerMetric(
            label: session.type == SessionType.rice ? 'SỐ BAO' : 'LƯỢT (CON)',
            value: session.type == SessionType.rice
                ? '${session.totalEntriesCount}'
                : '${session.totalEntriesCount} (${session.totalHeadCount})',
            valueColor: c.text,
            mutedColor: c.textMuted,
          ),
          _buildVerticalSep(c),
          _buildBannerMetric(
            label: 'CÂN THÔ',
            value: '${AppFormatters.formatWeight(session.grossWeight)} kg',
            valueColor: c.text,
            mutedColor: c.textMuted,
          ),
          _buildVerticalSep(c),
          _buildBannerMetric(
            label: 'CÂN TỊNH',
            value: '${AppFormatters.formatWeight(session.netWeight)} kg',
            valueColor: accentColor,
            mutedColor: c.textMuted,
          ),
          _buildVerticalSep(c),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'THÀNH TIỀN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.formatCurrency(session.totalAmount),
                  style: AppTokens.numericMetric(accentColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMetric({
    required String label,
    required String value,
    required Color valueColor,
    required Color mutedColor,
  }) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTokens.numericMetric(valueColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSep(AppColors c) {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
      color: c.border,
    );
  }

  /// TAB 1: Bảng cột + Bàn phím số vùng ngón cái (Thumb-zone Numpad >= 48dp)
  Widget _buildFastWeighingTab(
    AppProvider provider,
    WeighingSession session,
    AppColors c,
    Color accentColor,
    Color accentSoft,
  ) {
    final previewWeight = AppFormatters.parseFastWeight(
      _rawInput,
      autoOneDecimal: provider.autoOneDecimal,
    );

    final submitLabel = previewWeight != null
        ? 'LƯU\n${AppFormatters.formatCellWeight(previewWeight)} kg'
        : 'NHẬP\nMÃ CÂN';

    return Column(
      children: [
        Expanded(
          child: _buildMultiColumnGrid(
              provider, session, c, accentColor, accentSoft),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.borderStrong, width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space12,
            AppTokens.space8,
            AppTokens.space12,
            AppTokens.space8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh bật/tắt nhanh chế độ 1 số lẻ & giọng nói
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: provider.autoOneDecimal,
                      onSelected: (_) => provider.toggleAutoOneDecimal(),
                      label: Text(
                        provider.autoOneDecimal
                            ? 'Tự thêm 1 số lẻ (525 → 52.5)'
                            : 'Bấm dấu chấm thủ công',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      selectedColor: accentSoft,
                      checkmarkColor: accentColor,
                    ),
                    const SizedBox(width: AppTokens.space8),
                    FilterChip(
                      selected: provider.voiceEnabled,
                      onSelected: (_) => provider.toggleVoiceEnabled(),
                      avatar: Icon(
                        provider.voiceEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: 18,
                        color: provider.voiceEnabled ? accentColor : c.textMuted,
                      ),
                      label: const Text(
                        'Đọc tiếng Việt',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      selectedColor: accentSoft,
                      checkmarkColor: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space8),

              // Màn hình hiển thị số đang bấm (Tabular Figures)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: c.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  border: Border.all(
                    color: _rawInput.isNotEmpty ? accentColor : c.borderStrong,
                    width: _rawInput.isNotEmpty ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã #${session.totalEntriesCount + 1} • Cột ${(session.totalEntriesCount ~/ session.rowsPerColumn) + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            previewWeight != null
                                ? 'Sẽ lưu: ${AppFormatters.formatCellWeight(previewWeight)} kg (${AppFormatters.weightToSpeechText(previewWeight, isPig: session.type == SessionType.pig)})'
                                : 'Bấm số cân bên dưới rồi nhấn LƯU',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  previewWeight != null ? accentColor : c.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _rawInput.isEmpty ? '0.0' : _rawInput,
                      style: AppTokens.numericTitle(
                        _rawInput.isEmpty ? c.textMuted : c.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space8),

              // Bàn phím số ngoài đồng: mọi nút >= 50dp (vượt chuẩn 48dp Android & 44pt iOS)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildKeyRow(['7', '8', '9'], c),
                        const SizedBox(height: 6),
                        _buildKeyRow(['4', '5', '6'], c),
                        const SizedBox(height: 6),
                        _buildKeyRow(['1', '2', '3'], c),
                        const SizedBox(height: 6),
                        _buildKeyRow(['C', '0', '.'], c),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildActionKey(
                          label: 'XOÁ LÙI',
                          semanticLabel: 'Xoá 1 chữ số vừa gõ',
                          icon: Icons.backspace_outlined,
                          bgColor: c.surfaceSubtle,
                          fgColor: c.text,
                          borderColor: c.borderStrong,
                          height: 60,
                          onTap: () => _onKeyTap('BACK'),
                        ),
                        const SizedBox(height: 6),
                        _buildActionKey(
                          label: submitLabel,
                          semanticLabel:
                              'Lưu mã cân vào bảng và chuyển sang ô tiếp theo',
                          icon: Icons.check_circle_rounded,
                          bgColor: accentColor,
                          fgColor: c.onAccent,
                          borderColor: accentColor,
                          height: 152,
                          onTap: () => _submitWeight(provider, session),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys, AppColors c) {
    return Row(
      children: keys.map((k) {
        final isClear = k == 'C';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              height: 50, // >= 48dp minimum touch target
              child: Semantics(
                button: true,
                label: isClear ? 'Xoá toàn bộ số đang gõ' : 'Phím số $k',
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isClear ? c.dangerSoft : c.surface,
                    foregroundColor: isClear ? c.danger : c.text,
                    side: BorderSide(
                      color: isClear
                          ? c.danger.withOpacity(0.5)
                          : c.borderStrong,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                  onPressed: () => _onKeyTap(k),
                  child: Text(
                    k,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isClear ? c.danger : c.text,
                      fontFeatures: AppTokens.tabularNums,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionKey({
    required String label,
    required String semanticLabel,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required Color borderColor,
    required double height,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              side: BorderSide(color: borderColor),
            ),
          ),
          onPressed: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFeatures: AppTokens.tabularNums,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bảng nhiều cột: Mỗi ô cao 48dp để chạm sửa ngoài ruộng dễ dàng
  Widget _buildMultiColumnGrid(
    AppProvider provider,
    WeighingSession session,
    AppColors c,
    Color accentColor,
    Color accentSoft,
  ) {
    final totalCols =
        (session.totalEntriesCount ~/ session.rowsPerColumn) + 1;

    return SingleChildScrollView(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppTokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalCols, (colIndex) {
          final colEntries = session.getColumnEntries(colIndex);
          final colSubtotal = session.getColumnSubtotal(colIndex);
          final isCurrentCol = colIndex == totalCols - 1;

          return Container(
            width: 128,
            margin: const EdgeInsets.only(right: AppTokens.space12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isCurrentCol ? accentColor : c.borderStrong,
                width: isCurrentCol ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Cột
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrentCol ? accentColor : c.surfaceSubtle,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'CỘT ${colIndex + 1}',
                      style: TextStyle(
                        color: isCurrentCol ? c.onAccent : c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                // Các ô số cân: Khi 5 dòng/cột thì tự chia đều chiều cao (Expanded) để luôn hiện đủ 5 dòng không cần scroll
                Expanded(
                  child: session.rowsPerColumn == 5
                      ? Column(
                          children: List.generate(session.rowsPerColumn,
                              (rowIndex) {
                            return Expanded(
                              child: _buildCellRowWidget(
                                context: context,
                                provider: provider,
                                session: session,
                                colEntries: colEntries,
                                colIndex: colIndex,
                                rowIndex: rowIndex,
                                c: c,
                                accentColor: accentColor,
                                accentSoft: accentSoft,
                              ),
                            );
                          }),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: session.rowsPerColumn,
                          itemBuilder: (context, rowIndex) =>
                              _buildCellRowWidget(
                            context: context,
                            provider: provider,
                            session: session,
                            colEntries: colEntries,
                            colIndex: colIndex,
                            rowIndex: rowIndex,
                            c: c,
                            accentColor: accentColor,
                            accentSoft: accentSoft,
                          ),
                        ),
                ),
                // Tổng cột ở chân bảng
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.space8,
                    horizontal: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    border: Border(top: BorderSide(color: c.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.textMuted,
                        ),
                      ),
                      Text(
                        '${AppFormatters.formatCellWeight(colSubtotal)} kg',
                        style: AppTokens.numericMetric(accentColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCellRowWidget({
    required BuildContext context,
    required AppProvider provider,
    required WeighingSession session,
    required List<WeighingEntry> colEntries,
    required int colIndex,
    required int rowIndex,
    required AppColors c,
    required Color accentColor,
    required Color accentSoft,
  }) {
    final globalIndex = colIndex * session.rowsPerColumn + rowIndex;
    final hasEntry = rowIndex < colEntries.length;
    final entry = hasEntry ? colEntries[rowIndex] : null;
    final isNextActiveCell = globalIndex == session.totalEntriesCount;

    return Semantics(
      button: entry != null,
      label: entry != null
          ? 'Mã cân số ${globalIndex + 1}, ${AppFormatters.formatCellWeight(entry.weight)} kg. Chạm để sửa hoặc xoá.'
          : 'Ô trống số ${globalIndex + 1}',
      child: InkWell(
        onTap: entry == null
            ? null
            : () => _showEditEntryDialog(
                context, provider, session, entry, globalIndex + 1),
        child: Container(
          constraints: session.rowsPerColumn == 5
              ? const BoxConstraints()
              : const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
          decoration: BoxDecoration(
            color: isNextActiveCell
                ? accentSoft.withOpacity(0.55)
                : Colors.transparent,
            border: Border(bottom: BorderSide(color: c.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${globalIndex + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: c.textMuted,
                  fontFeatures: AppTokens.tabularNums,
                ),
              ),
              if (entry != null)
                Row(
                  children: [
                    Text(
                      AppFormatters.formatCellWeight(entry.weight),
                      style: AppTokens.numericCell(c.text),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: c.textMuted,
                    ),
                  ],
                )
              else if (isNextActiveCell)
                Text(
                  'Chờ nhập...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                )
              else
                Text(
                  '—',
                  style: TextStyle(color: c.textMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditEntryDialog(
    BuildContext context,
    AppProvider provider,
    WeighingSession session,
    WeighingEntry entry,
    int orderNumber,
  ) async {
    final weightCtrl = TextEditingController(
      text: AppFormatters.formatCellWeight(entry.weight),
    );

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return AlertDialog(
            title: Text('Sửa mã cân #$orderNumber'),
            content: TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Khối lượng (gõ 1233 ➔ 123.3 kg)',
                suffixText: 'kg',
              ),
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: c.danger,
                  minimumSize: const Size(
                    AppTokens.minTouchTarget,
                    AppTokens.minTouchTarget,
                  ),
                ),
                onPressed: () async {
                  await provider.removeWeighingEntry(session.id, entry.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xoá mã này'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    AppTokens.minTouchTarget,
                    AppTokens.minTouchTarget,
                  ),
                ),
                onPressed: () async {
                  final text = weightCtrl.text.trim().replaceAll(',', '.');
                  double? newWeight = double.tryParse(text);
                  if (newWeight != null && !text.contains('.') && text.length >= 3) {
                    newWeight = newWeight / 10.0;
                  }
                  if (newWeight != null && newWeight > 0) {
                    await provider.editWeighingEntry(
                      session.id,
                      entryId: entry.id,
                      newWeight: newWeight,
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Lưu thay đổi'),
              ),
            ],
          );
        },
      );
  }

  /// TAB 2: Tính Trừ Bì, Trừ Độ Ẩm, Đơn Giá & Tiền Cọc (Không lồng Card-in-Card)
  Widget _buildCalculationTab(
    AppProvider provider,
    WeighingSession session,
    AppColors c,
    Color accentColor,
    Color accentSoft,
  ) {
    final isRice = session.type == SessionType.rice;

    return ListView(
      padding: const EdgeInsets.all(AppTokens.space16),
      children: [
        // Mục 1: Trừ bì
        Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRice ? '1. QUY TẮC TRỪ BÌ BAO LÚA' : '1. QUY TẮC TRỪ BÌ LỒNG HEO',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: c.text,
                ),
              ),
              if (isRice) ...[
                DropdownButtonFormField<TareMode>(
                  value: session.tareMode,
                  dropdownColor: c.elevated,
                  decoration: const InputDecoration(
                    labelText: 'Phương thức trừ bì',
                  ),
                  items: TareMode.values
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      double defaultVal = session.tareValue;
                      if (mode == TareMode.bagsPerKg) defaultVal = 8.0;
                      if (mode == TareMode.kgPerUnit) {
                        defaultVal = 0.15;
                      }
                      _tareValueCtrl.text =
                          AppFormatters.formatCellWeight(defaultVal);
                      provider.updateSession(
                        session.copyWith(tareMode: mode, tareValue: defaultVal),
                      );
                    }
                  },
                ),
                const SizedBox(height: AppTokens.space12),
              ],
              TextField(
                controller: _tareValueCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isRice
                      ? session.tareMode == TareMode.bagsPerKg
                          ? 'Số bao quy đổi 1 kg (VD: 7 hoặc 8 bao = 1 kg)'
                          : session.tareMode == TareMode.kgPerUnit
                              ? 'Số kg bì trên mỗi bao'
                              : 'Tổng số kg bì trừ trực tiếp'
                      : 'Số kg trừ bì mỗi lồng heo (kg/lồng)',
                  suffixText:
                      session.tareMode == TareMode.bagsPerKg ? 'bao/kg' : 'kg',
                ),
                onChanged: (val) {
                  final parsed =
                      double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                  provider.updateSession(session.copyWith(tareValue: parsed));
                },
              ),
              const SizedBox(height: AppTokens.space8),
              Wrap(
                spacing: AppTokens.space8,
                runSpacing: AppTokens.space4,
                children: (session.tareMode == TareMode.bagsPerKg
                        ? [6.0, 7.0, 8.0, 10.0]
                        : isRice
                            ? [0.1, 0.15, 0.2]
                            : [10.0, 12.0, 15.0, 20.0])
                    .map((preset) {
                  final label = session.tareMode == TareMode.bagsPerKg
                      ? '${preset.toInt()} bao = 1kg'
                      : '$preset kg/${session.type.unitName}';
                  return ActionChip(
                    label: Text(label, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _tareValueCtrl.text =
                          AppFormatters.formatCellWeight(preset);
                      provider
                          .updateSession(session.copyWith(tareValue: preset));
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Làm tròn số kg trừ bì đến 0.5 kg',
                  style: TextStyle(fontSize: 14, color: c.text),
                ),
                value: session.roundTareToHalfKg,
                activeColor: accentColor,
                onChanged: (val) {
                  provider
                      .updateSession(session.copyWith(roundTareToHalfKg: val));
                },
              ),
              Divider(color: c.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Số kg trừ bì:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  Text(
                    '- ${AppFormatters.formatWeight(session.tareWeight, showUnit: true)}',
                    style: AppTokens.numericMetric(c.danger),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space12),

        // Mục 2: Trừ tạp chất / độ ẩm
        Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2. TRỪ TẠP CHẤT / ĐỘ ẨM (TUỲ CHỌN)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: c.text,
                ),
              ),
              const SizedBox(height: AppTokens.space12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _impurityPercentCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Trừ theo tỷ lệ %',
                        suffixText: '%',
                      ),
                      onChanged: (val) {
                        final parsed =
                            double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                        provider.updateSession(
                            session.copyWith(impurityPercent: parsed));
                      },
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: TextField(
                      controller: _impurityKgCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Hoặc trừ thẳng kg',
                        suffixText: 'kg',
                      ),
                      onChanged: (val) {
                        final parsed =
                            double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                        provider.updateSession(
                            session.copyWith(impurityFixedKg: parsed));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space12),

        // Mục 3: Đơn giá & Tiền cọc
        Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3. ĐƠN GIÁ & TIỀN ĐẶT CỌC',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: c.text,
                ),
              ),
              const SizedBox(height: AppTokens.space12),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Đơn giá thu mua (VNĐ / 1 kg)',
                  suffixText: 'đ/kg',
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(
                          val.replaceAll('.', '').replaceAll(',', '')) ??
                      0.0;
                  provider.updateSession(session.copyWith(pricePerKg: parsed));
                },
              ),
              const SizedBox(height: AppTokens.space8),
              Wrap(
                spacing: AppTokens.space8,
                runSpacing: AppTokens.space4,
                children: (isRice
                        ? [7500.0, 8000.0, 8500.0, 9000.0, 9500.0]
                        : [58000.0, 62000.0, 65000.0, 68000.0, 72000.0])
                    .map((price) {
                  return ActionChip(
                    label: Text(
                      '${AppFormatters.formatCurrency(price, showSymbol: false)} đ',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      _priceCtrl.text = price.round().toString();
                      provider
                          .updateSession(session.copyWith(pricePerKg: price));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTokens.space12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tiền đặt cọc trước',
                        suffixText: 'đ',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(
                                val.replaceAll('.', '').replaceAll(',', '')) ??
                            0.0;
                        provider.updateSession(
                            session.copyWith(depositAmount: parsed));
                      },
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: TextField(
                      controller: _extraCostCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Chi phí phụ (bốc vác)',
                        suffixText: 'đ',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(
                                val.replaceAll('.', '').replaceAll(',', '')) ??
                            0.0;
                        provider.updateSession(
                            session.copyWith(extraCostAmount: parsed));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space12),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú phiếu cân',
                ),
                onChanged: (val) {
                  provider.updateSession(session.copyWith(note: val));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space16),

        // Mục 4: Tổng kết thanh toán rõ ràng
        Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: accentColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TỔNG KẾT THANH TOÁN PHIẾU CÂN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: c.text,
                ),
              ),
              Divider(height: 20, color: c.border),
              _buildCalcSummaryRow(
                'Tổng cân thô (${session.totalEntriesCount} ${session.type.unitName}):',
                AppFormatters.formatWeight(session.grossWeight, showUnit: true),
                c: c,
              ),
              _buildCalcSummaryRow(
                'Trừ bì:',
                '- ${AppFormatters.formatWeight(session.tareWeight, showUnit: true)}',
                c: c,
                valueColor: c.danger,
              ),
              if (session.impurityWeight > 0)
                _buildCalcSummaryRow(
                  'Trừ tạp chất / độ ẩm:',
                  '- ${AppFormatters.formatWeight(session.impurityWeight, showUnit: true)}',
                  c: c,
                  valueColor: c.danger,
                ),
              _buildCalcSummaryRow(
                'SAU KHI TRỪ BÌ:',
                AppFormatters.formatWeight(session.netWeight, showUnit: true),
                c: c,
                isBold: true,
                valueColor: accentColor,
              ),
              _buildCalcSummaryRow(
                isRice ? 'Bình quân 1 bao:' : 'Bình quân 1 con heo:',
                '${AppFormatters.formatWeight(session.averageWeight, showUnit: true)} / ${session.type.subUnitName}',
                c: c,
                isBold: true,
              ),
              Divider(height: 20, color: c.border),
              _buildCalcSummaryRow(
                'Đơn giá:',
                '${AppFormatters.formatCurrency(session.pricePerKg)} / kg',
                c: c,
              ),
              _buildCalcSummaryRow(
                'Tổng thành tiền:',
                AppFormatters.formatCurrency(session.totalAmount),
                c: c,
                isBold: true,
              ),
              if (session.depositAmount > 0)
                _buildCalcSummaryRow(
                  'Trừ tiền đặt cọc:',
                  '- ${AppFormatters.formatCurrency(session.depositAmount)}',
                  c: c,
                  valueColor: c.danger,
                ),
              if (session.extraCostAmount > 0)
                _buildCalcSummaryRow(
                  'Trừ chi phí phụ:',
                  '- ${AppFormatters.formatCurrency(session.extraCostAmount)}',
                  c: c,
                  valueColor: c.danger,
                ),
              const SizedBox(height: AppTokens.space12),
              Container(
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
                          AppFormatters.formatCurrency(session.remainingAmount),
                          style: AppTokens.numericTitle(accentColor)
                              .copyWith(fontSize: 20),
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
              const SizedBox(height: AppTokens.space8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Đánh dấu đã thanh toán đủ (Tất toán)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                value: session.isPaid,
                activeColor: accentColor,
                onChanged: (val) {
                  provider.updateSession(session.copyWith(isPaid: val));
                },
              ),
              const SizedBox(height: AppTokens.space8),
              SizedBox(
                width: double.infinity,
                height: AppTokens.minTouchTarget,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: c.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(
                    'XUẤT PHIẾU (${AppFormatters.formatCurrency(session.remainingAmount)})',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReceiptPreviewScreen(sessionId: session.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space24),
      ],
    );
  }

  Widget _buildCalcSummaryRow(
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
            style: TextStyle(
              fontSize: 14,
              color: isBold ? c.text : c.textMuted,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
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
