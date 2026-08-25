import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/entities/staff.dart';
import '../state/shop_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _countryCode = '+88';

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ShopStore>().ownerProfile;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: _localPhoneDigits(p.phone));
    _email = TextEditingController(text: p.email);
  }

  /// Strip +880 / 880 so the field shows the 11 local digits only.
  static String _localPhoneDigits(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('880') && digits.length > 11) {
      digits = digits.substring(3);
    }
    if (digits.length > 11) {
      digits = digits.substring(digits.length - 11);
    }
    return digits;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final localPhone = _phone.text.trim();
    final error = await store.saveOwnerProfile(
      OwnerProfile(
        name: _name.text,
        phone: localPhone.isEmpty ? '' : '$_countryCode$localPhone',
        email: _email.text,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    showAppMessage(context, t.profileSaved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final shopName = store.shop?.name ?? 'Shop Manager';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (_name.text.trim().isEmpty ? 'O' : _name.text.trim()[0])
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.ownerRole,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[\p{L}\s]', unicode: true),
              ),
            ],
            decoration: InputDecoration(labelText: t.userName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: InputDecoration(
              labelText: t.phone,
              prefixText: '$_countryCode ',
              hintText: '01XXXXXXXXX',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: t.email),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _saving ? '...' : t.save,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
