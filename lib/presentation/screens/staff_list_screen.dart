import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/entities/staff.dart';
import '../state/shop_store.dart';
import 'staff_form_screen.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key, this.focusAccess = false});

  final bool focusAccess;

  String _roleLabel(AppText t, StaffRole role) {
    return switch (role) {
      StaffRole.cashier => t.roleCashier,
      StaffRole.manager => t.roleManager,
      StaffRole.admin => t.roleAdmin,
      StaffRole.custom => t.roleCustom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final staff = store.staff;

    return Scaffold(
      appBar: AppBar(
        title: Text(focusAccess ? t.accessLevels : t.manageStaff),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaffFormScreen()),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(t.addStaff),
      ),
      body: staff.isEmpty
          ? Center(
              child: Text(
                t.noStaff,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: staff.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final member = staff[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StaffFormScreen(staff: member),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: member.active
                          ? AppColors.primaryLight
                          : AppColors.border,
                      child: Icon(
                        Icons.badge_outlined,
                        color: member.active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      focusAccess
                          ? '${_roleLabel(t, member.role)} • '
                              '${[
                                if (member.canSell) t.permSell,
                                if (member.canProducts) t.permProducts,
                                if (member.canDues) t.permDues,
                                if (member.canReports) t.permReports,
                              ].join(', ')}'
                          : '${member.phone} • ${_roleLabel(t, member.role)}'
                              '${member.active ? '' : ' • off'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
