import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/tap_mark.dart';
import '../state/shop_store.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'staff_form_screen.dart';
import 'staff_list_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

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
    ];

    return SafeArea(
      child: ListView(
        children: [
          ScreenHeader(
            title: t.moreTitle,
            subtitle: t.moreHint,
            trailing: OfflineBadge(label: t.offline),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TapHint(
              number: 1,
              text: 'Profile, staff, access levels, and settings',
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Card(
                child: ListTile(
                  onTap: item.onTap,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(item.icon, color: AppColors.primary),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
