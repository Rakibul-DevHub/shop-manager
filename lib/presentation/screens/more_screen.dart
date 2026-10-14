import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/screen_header.dart';
import '../state/shop_store.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'staff_form_screen.dart';
import 'staff_list_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(t.logout),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await store.logout();
    // AppGate switches to ShopSetupScreen when shop is cleared.
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final profileName = store.ownerProfile.name.trim().isEmpty
        ? t.ownerRole
        : store.ownerProfile.name;

    final items = [
      _MoreItem(
        title: t.profile,
        subtitle: '$profileName • ${t.profileHint}',
        icon: Icons.person_outline,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.addStaff,
        subtitle: t.addStaffHint,
        icon: Icons.person_add_alt_1_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaffFormScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.manageStaff,
        subtitle: '${t.manageStaffHint} (${store.staff.length})',
        icon: Icons.groups_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaffListScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.accessLevels,
        subtitle: t.accessLevelsHint,
        icon: Icons.admin_panel_settings_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const StaffListScreen(focusAccess: true),
            ),
          );
        },
      ),
      _MoreItem(
        title: t.settings,
        subtitle: t.settingsHint,
        icon: Icons.settings_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.logout,
        subtitle: t.logoutHint,
        icon: Icons.logout,
        danger: true,
        onTap: () => _confirmLogout(context),
      ),
    ];

    return SafeArea(
      child: ListView(
        children: [
          ScreenHeader(
            title: t.moreTitle,
            subtitle: t.moreHint,
            trailing: OfflineBadge(label: t.offline),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Card(
                child: ListTile(
                  onTap: item.onTap,
                  leading: CircleAvatar(
                    backgroundColor: item.danger
                        ? AppColors.danger.withValues(alpha: 0.12)
                        : AppColors.primaryLight,
                    child: Icon(
                      item.icon,
                      color: item.danger ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: item.danger ? AppColors.danger : null,
                    ),
                  ),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
}
