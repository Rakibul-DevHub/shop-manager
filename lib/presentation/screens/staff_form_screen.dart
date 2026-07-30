import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/entities/staff.dart';
import '../state/shop_store.dart';

class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({super.key, this.staff});

  final StaffMember? staff;

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late StaffMember _draft;
  bool _saving = false;

  bool get _isEdit => widget.staff != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.staff;
    _draft = existing ??
        StaffMember(
          name: '',
          phone: '',
          role: StaffRole.cashier,
          createdAt: DateTime.now(),
        ).withRoleDefaults(StaffRole.cashier);
    _name = TextEditingController(text: _draft.name);
    _phone = TextEditingController(text: _draft.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _roleLabel(AppText t, StaffRole role) {
    return switch (role) {
      StaffRole.cashier => t.roleCashier,
      StaffRole.manager => t.roleManager,
      StaffRole.admin => t.roleAdmin,
      StaffRole.custom => t.roleCustom,
    };
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final error = await store.saveStaff(
      _draft.copyWith(name: _name.text, phone: _phone.text),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    showAppMessage(context, t.staffSaved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final id = widget.staff?.id;
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteStaff),
        content: Text(t.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await store.deleteStaff(id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? t.editStaff : t.addStaff),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: t.deleteStaff,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: t.staffName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: t.staffPhone),
          ),
          const SizedBox(height: 16),
          Text(
            t.staffRole,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StaffRole.values.map((role) {
              final selected = _draft.role == role;
              return ChoiceChip(
                label: Text(_roleLabel(t, role)),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                checkmarkColor: Colors.white,
                onSelected: (_) {
                  setState(() {
                    _draft = role == StaffRole.custom
                        ? _draft.copyWith(role: role)
                        : _draft.withRoleDefaults(role);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.staffActive),
            value: _draft.active,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(active: v)),
          ),
          const Divider(height: 28),
          Text(
            t.permissions,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            t.accessLevelsHint,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _PermTile(
            label: t.permSell,
            value: _draft.canSell,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canSell: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permProducts,
            value: _draft.canProducts,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canProducts: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permDues,
            value: _draft.canDues,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canDues: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permExpenses,
            value: _draft.canExpenses,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canExpenses: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permReports,
            value: _draft.canReports,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canReports: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permSettings,
            value: _draft.canSettings,
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(canSettings: v, role: StaffRole.custom);
            }),
          ),
          _PermTile(
            label: t.permManageStaff,
            value: _draft.canManageStaff,
            onChanged: (v) => setState(() {
              _draft =
                  _draft.copyWith(canManageStaff: v, role: StaffRole.custom);
            }),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _saving ? '...' : t.saveStaff,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _PermTile extends StatelessWidget {
  const _PermTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
