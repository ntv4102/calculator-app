import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weighing_models.dart';
import '../providers/app_provider.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';
import 'contacts_screen.dart';
import 'receipt_preview_screen.dart';
import 'statistics_screen.dart';
import 'weighing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _SessionsDashboardTab(),
      const ContactsScreen(),
      const StatisticsScreen(),
    ];

    return Scaffold(
      body: pages[_currentTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.scale_outlined),
            selectedIcon: Icon(Icons.scale_rounded),
            label: 'Phiếu Cân',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Danh Bạ',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Thống Kê',
          ),
        ],
      ),
    );
  }
}

class _SessionsDashboardTab extends StatelessWidget {
  const _SessionsDashboardTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final c = AppColors.of(context);

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: c.background,
        body: const Center(
          child: Semantics(
            label: 'Đang tải dữ liệu phiếu cân',
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Tạm thời chỉ hiển thị phiếu cân heo khi chức năng cân lúa đang phát triển
    final sessions = provider.filteredSessions
        .where((s) => s.type == SessionType.pig)
        .toList();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sổ Cân Heo',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: c.text,
              ),
            ),
            Text(
              provider.isDarkMode
                  ? 'Chế độ cân ban đêm (Chống chói OLED)'
                  : 'Chế độ ngoài trời (Tương phản cao)',
              style: TextStyle(fontSize: 12, color: c.textMuted),
            ),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: provider.isDarkMode
                ? 'Chuyển sang giao diện sáng ngoài nắng'
                : 'Chuyển sang giao diện tối cân ban đêm',
            child: IconButton(
              constraints: const BoxConstraints(
                minWidth: AppTokens.minTouchTarget,
                minHeight: AppTokens.minTouchTarget,
              ),
              tooltip: provider.isDarkMode
                  ? 'Bật giao diện Sáng (Ngoài nắng)'
                  : 'Bật giao diện Tối (Cân đêm)',
              icon: Icon(
                provider.isDarkMode
                    ? Icons.wb_sunny_outlined
                    : Icons.dark_mode_outlined,
                color: c.text,
              ),
              onPressed: () => provider.toggleDarkMode(),
            ),
          ),
          const SizedBox(width: AppTokens.space4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            // Hành động chính: Tạo phiếu Cân Heo Mới
            _buildActionLaunchTile(
              context: context,
              title: 'Cân Heo Mới',
              subtitle: '• Tính tiền tự động',
              icon: Icons.pets_rounded,
              accentColor: c.accentPig,
              softBgColor: c.accentPigSoft,
              textColor: c.text,
              mutedColor: c.textMuted,
              onTap: () => _showNewSessionDialog(
                  context, provider, SessionType.pig),
            ),
            const SizedBox(height: AppTokens.space20),

            // Tiêu đề danh sách
            Text(
              'PHIẾU CÂN GẦN ĐÂY (${sessions.length})',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.4,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: AppTokens.space8),

            // Empty State hướng dẫn hành động rõ ràng
            if (sessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppTokens.space24),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.scale_outlined, size: 40, color: c.textMuted),
                    const SizedBox(height: AppTokens.space12),
                    Text(
                      'Chưa có phiếu cân nào',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: c.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      'Nhấn "Cân Heo Mới" phía trên để bắt đầu ghi số cân.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: c.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...sessions.map(
                (session) => _buildSessionRowCard(context, provider, session, c),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionLaunchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color softBgColor,
    required Color textColor,
    required Color mutedColor,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Semantics(
      button: true,
      enabled: !disabled,
      label: '$title, $subtitle',
      child: Material(
        color: accentColor,
        borderRadius: BorderRadius.circular(18),
        elevation: 3,
        shadowColor: accentColor.withOpacity(0.4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Icon avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🐷', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '+ Tạo mới',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionRowCard(
    BuildContext context,
    AppProvider provider,
    WeighingSession session,
    AppColors c,
  ) {
    final isRice = session.type == SessionType.rice;
    final typeAccent = isRice ? c.accentRice : c.accentPig;
    final typeSoft = isRice ? c.accentRiceSoft : c.accentPigSoft;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeighingScreen(sessionId: session.id),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng 1: Loại phiếu + Trạng thái thanh toán ở 2 bên
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space8,
                        vertical: AppTokens.space4,
                      ),
                      decoration: BoxDecoration(
                        color: typeSoft,
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Text(
                        session.type.shortLabel.toUpperCase(),
                        style: TextStyle(
                          color: typeAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space8,
                        vertical: AppTokens.space4,
                      ),
                      decoration: BoxDecoration(
                        color: session.isPaid ? c.successSoft : c.warningSoft,
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            session.isPaid
                                ? Icons.check_circle_outline_rounded
                                : Icons.schedule_rounded,
                            size: 14,
                            color: session.isPaid ? c.success : c.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.isPaid ? 'Đã tất toán' : 'Còn nợ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: session.isPaid ? c.success : c.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space8),
                // Hàng 2: Tên phiếu cân (xuống hàng riêng)
                Text(
                  session.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: c.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Hàng 3: Khách hàng
                Text(
                  'Khách: ${session.partnerName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Hàng 3: Thời gian cân
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: c.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.formatDateTime(session.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textMuted,
                        fontFeatures: AppTokens.tabularNums,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
                  child: Divider(height: 1, color: c.border),
                ),
                // Hàng 3: Số liệu Tabular (Số bao/con, Khối lượng tịnh, Còn thanh toán)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn(
                      label: isRice ? 'Số lượng' : 'Số lượt (con)',
                      value: isRice
                          ? '${session.totalEntriesCount} bao'
                          : '${session.totalEntriesCount} (${session.totalHeadCount}c)',
                      c: c,
                    ),
                    _buildMetricColumn(
                      label: 'Khối lượng tịnh',
                      value: AppFormatters.formatWeight(session.netWeight,
                          showUnit: true),
                      c: c,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Còn thanh toán',
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.formatCurrency(session.remainingAmount),
                          style: AppTokens.numericMetric(typeAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space8),
                // Hàng 4: Các nút thao tác có vùng chạm >= 48dp, tách nút Xoá sang góc an toàn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Xoá phiếu cân ${session.title}',
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: c.danger,
                          minimumSize: const Size(
                            AppTokens.minTouchTarget,
                            AppTokens.minTouchTarget,
                          ),
                        ),
                        onPressed: () =>
                            _confirmDeleteSession(context, provider, session),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Xoá'),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: c.text,
                            minimumSize: const Size(
                              AppTokens.minTouchTarget,
                              AppTokens.minTouchTarget,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptPreviewScreen(
                                    sessionId: session.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Phiếu in / Zalo'),
                        ),
                        const SizedBox(width: AppTokens.space4),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            backgroundColor: typeSoft,
                            foregroundColor: typeAccent,
                            minimumSize: const Size(
                              AppTokens.minTouchTarget,
                              AppTokens.minTouchTarget,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WeighingScreen(sessionId: session.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note_rounded, size: 20),
                          label: const Text(
                            'Mở Bảng Cân',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required AppColors c,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: c.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTokens.numericMetric(c.text),
        ),
      ],
    );
  }

  Future<void> _showNewSessionDialog(
    BuildContext context,
    AppProvider provider,
    SessionType type,
  ) async {
    final isRice = type == SessionType.rice;
    final titleCtrl = TextEditingController(
      text: isRice ? 'Lúa Đài Thơm 8' : 'Xuất Heo Thịt',
    );
    final partnerNameCtrl = TextEditingController();
    final partnerPhoneCtrl = TextEditingController();
    final priceCtrl = TextEditingController(
      text: isRice ? '8.500' : '65.000',
    );

    final partnerFocus = FocusNode();
    final priceFocus = FocusNode();

    String selectedContactId = '';
    int rowsPerCol = 5;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                isRice ? 'Tạo Phiếu Cân Lúa Mới' : 'Tạo Phiếu Cân Heo Mới',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => partnerFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: isRice
                            ? 'Tên phiếu / Giống lúa'
                            : 'Tên phiếu / Chuồng heo',
                        helperText: isRice
                            ? 'Ví dụ: Lúa OM18, Đài Thơm 8'
                            : 'Ví dụ: Heo thịt trại khu A',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),
                    if (provider.contacts.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: selectedContactId.isEmpty
                            ? null
                            : selectedContactId,
                        decoration: const InputDecoration(
                          labelText: 'Chọn nhanh từ Danh bạ',
                        ),
                        items: provider.contacts
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text('${c.name} (${c.role})'),
                                ))
                            .toList(),
                        onChanged: (contactId) {
                          if (contactId == null) return;
                          final c = provider.contacts
                              .firstWhere((e) => e.id == contactId);
                          setDialogState(() {
                            selectedContactId = c.id;
                            partnerNameCtrl.text = c.name;
                            partnerPhoneCtrl.text = c.phone;
                          });
                        },
                      ),
                      const SizedBox(height: AppTokens.space12),
                    ],
                    TextField(
                      controller: partnerNameCtrl,
                      focusNode: partnerFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => priceFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Tên người bán',
                        hintText: 'Ví dụ: Anh Tư Sang',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),
                    TextField(
                      controller: priceCtrl,
                      focusNode: priceFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (val) {
                        final clean = val.replaceAll(RegExp(r'\D'), '');
                        if (clean.isEmpty) {
                          priceCtrl.value = const TextEditingValue(text: '');
                          return;
                        }
                        final formatted = clean.replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]}.',
                        );
                        priceCtrl.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      },
                      decoration: const InputDecoration(
                        labelText: 'Đơn giá thu mua (đ/kg)',
                        hintText: 'Ví dụ: 65.000',
                        suffixText: 'đ/kg',
                      ),
                    ),
                  ],
                ),
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
                    final price = double.tryParse(
                            priceCtrl.text.replaceAll('.', '').trim()) ??
                        0.0;
                    final created = await provider.createNewSession(
                      type: type,
                      title: titleCtrl.text,
                      partnerId: selectedContactId,
                      partnerName: partnerNameCtrl.text,
                      partnerPhone: partnerPhoneCtrl.text,
                      pricePerKg: price,
                      rowsPerColumn: 5,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WeighingScreen(sessionId: created.id),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isRice ? 'Mở Bảng Cân Lúa' : 'Mở Bảng Cân Heo',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteSession(
    BuildContext context,
    AppProvider provider,
    WeighingSession session,
  ) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: const Text('Xoá phiếu cân?'),
        content: Text(
            'Phiếu "${session.title}" (${session.totalEntriesCount} ${session.type.unitName}) sẽ bị xoá vĩnh viễn.'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppTokens.minTouchTarget,
                AppTokens.minTouchTarget,
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).danger,
              minimumSize: const Size(
                AppTokens.minTouchTarget,
                AppTokens.minTouchTarget,
              ),
            ),
            onPressed: () async {
              await provider.deleteSession(session.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Xoá phiếu cân'),
          ),
        ],
      ),
    );
  }
}
