import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final contacts = provider.contacts;
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        title: const Text('Danh Bạ Nông Dân & Thương Lái'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.accentRice,
        foregroundColor: c.onAccent,
        onPressed: () => _showAddContactDialog(context, provider),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Thêm Khách Hàng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: contacts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 44, color: c.textMuted),
                      const SizedBox(height: AppTokens.space12),
                      Text(
                        'Chưa có khách hàng trong danh bạ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        'Lưu thông tin nông dân, chủ trại hoặc thương lái để chọn nhanh khi tạo phiếu cân mới.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppTokens.space16),
                itemCount: contacts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTokens.space12),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final partnerSessions = provider.sessions
                      .where((s) =>
                          s.partnerId == contact.id ||
                          s.partnerName.toLowerCase() ==
                              contact.name.toLowerCase())
                      .toList();
                  final totalNetKg = partnerSessions.fold(
                      0.0, (sum, s) => sum + s.netWeight);
                  final totalMoney = partnerSessions.fold(
                      0.0, (sum, s) => sum + s.totalAmount);

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
                            Expanded(
                              child: Text(
                                contact.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: c.text,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTokens.space8,
                                vertical: AppTokens.space4,
                              ),
                              decoration: BoxDecoration(
                                color: c.accentRiceSoft,
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusSm),
                              ),
                              child: Text(
                                contact.role,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.accentRice,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Semantics(
                              button: true,
                              label: 'Xoá liên hệ ${contact.name}',
                              child: IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: AppTokens.minTouchTarget,
                                  minHeight: AppTokens.minTouchTarget,
                                ),
                                icon: Icon(Icons.delete_outline,
                                    color: c.textMuted),
                                onPressed: () =>
                                    provider.deleteContact(contact.id),
                              ),
                            ),
                          ],
                        ),
                        if (contact.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'SĐT: ${contact.phone}',
                              style: TextStyle(
                                fontSize: 14,
                                color: c.text,
                                fontFeatures: AppTokens.tabularNums,
                              ),
                            ),
                          ),
                        if (contact.address.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Địa chỉ: ${contact.address}',
                              style:
                                  TextStyle(fontSize: 13, color: c.textMuted),
                            ),
                          ),
                        if (contact.note.isNotEmpty)
                          Text(
                            'Ghi chú: ${contact.note}',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: c.textMuted,
                            ),
                          ),
                        Divider(height: 20, color: c.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã giao dịch: ${partnerSessions.length} phiếu (${AppFormatters.formatWeight(totalNetKg, showUnit: true)})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.textMuted,
                                fontFeatures: AppTokens.tabularNums,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(totalMoney),
                              style: AppTokens.numericMetric(c.accentRice),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddContactDialog(
    BuildContext context,
    AppProvider provider,
  ) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final phoneFocus = FocusNode();
    final addressFocus = FocusNode();
    final noteFocus = FocusNode();
    String role = 'Nông dân';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm Nông Dân / Thương Lái'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => phoneFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Họ tên (VD: Chú Bảy Thành)',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(
                        labelText: 'Vai trò',
                      ),
                      items: ['Nông dân', 'Thương lái', 'Chủ trại', 'Khách lẻ']
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => role = val);
                      },
                    ),
                    const SizedBox(height: AppTokens.space12),
                    TextField(
                      controller: phoneCtrl,
                      focusNode: phoneFocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => addressFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),
                    TextField(
                      controller: addressCtrl,
                      focusNode: addressFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => noteFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ / Khu vực ruộng / Trại',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),
                    TextField(
                      controller: noteCtrl,
                      focusNode: noteFocus,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
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
                    if (nameCtrl.text.trim().isEmpty) return;
                    await provider.addContact(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      role: role,
                      address: addressCtrl.text,
                      note: noteCtrl.text,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Lưu Danh Bạ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
