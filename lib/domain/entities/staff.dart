class StaffMember {
  const StaffMember({
    this.id,
    required this.name,
    required this.phone,
    this.role = StaffRole.cashier,
    this.active = true,
    this.canSell = true,
    this.canProducts = false,
    this.canDues = false,
    this.canExpenses = false,
    this.canReports = false,
    this.canSettings = false,
    this.canManageStaff = false,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String phone;
  final StaffRole role;
  final bool active;
  final bool canSell;
  final bool canProducts;
  final bool canDues;
  final bool canExpenses;
  final bool canReports;
  final bool canSettings;
  final bool canManageStaff;
  final DateTime createdAt;

  StaffMember copyWith({
    int? id,
    String? name,
    String? phone,
    StaffRole? role,
    bool? active,
    bool? canSell,
    bool? canProducts,
    bool? canDues,
    bool? canExpenses,
    bool? canReports,
    bool? canSettings,
    bool? canManageStaff,
    DateTime? createdAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      active: active ?? this.active,
      canSell: canSell ?? this.canSell,
      canProducts: canProducts ?? this.canProducts,
      canDues: canDues ?? this.canDues,
      canExpenses: canExpenses ?? this.canExpenses,
      canReports: canReports ?? this.canReports,
      canSettings: canSettings ?? this.canSettings,
      canManageStaff: canManageStaff ?? this.canManageStaff,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Apply a preset role's default access flags.
  StaffMember withRoleDefaults(StaffRole nextRole) {
    return switch (nextRole) {
      StaffRole.cashier => copyWith(
          role: nextRole,
          canSell: true,
          canProducts: false,
          canDues: false,
          canExpenses: false,
          canReports: false,
          canSettings: false,
          canManageStaff: false,
        ),
      StaffRole.manager => copyWith(
          role: nextRole,
          canSell: true,
          canProducts: true,
          canDues: true,
          canExpenses: true,
          canReports: true,
          canSettings: false,
          canManageStaff: false,
        ),
      StaffRole.admin => copyWith(
          role: nextRole,
          canSell: true,
          canProducts: true,
          canDues: true,
          canExpenses: true,
          canReports: true,
          canSettings: true,
          canManageStaff: true,
        ),
      StaffRole.custom => copyWith(role: nextRole),
    };
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.name,
        'active': active ? 1 : 0,
        'can_sell': canSell ? 1 : 0,
        'can_products': canProducts ? 1 : 0,
        'can_dues': canDues ? 1 : 0,
        'can_expenses': canExpenses ? 1 : 0,
        'can_reports': canReports ? 1 : 0,
        'can_settings': canSettings ? 1 : 0,
        'can_manage_staff': canManageStaff ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory StaffMember.fromMap(Map<String, Object?> map) {
    return StaffMember(
      id: map['id'] as int?,
      name: map['name']! as String,
      phone: map['phone']! as String,
      role: StaffRole.fromName(map['role'] as String?),
      active: (map['active'] as int? ?? 1) == 1,
      canSell: (map['can_sell'] as int? ?? 0) == 1,
      canProducts: (map['can_products'] as int? ?? 0) == 1,
      canDues: (map['can_dues'] as int? ?? 0) == 1,
      canExpenses: (map['can_expenses'] as int? ?? 0) == 1,
      canReports: (map['can_reports'] as int? ?? 0) == 1,
      canSettings: (map['can_settings'] as int? ?? 0) == 1,
      canManageStaff: (map['can_manage_staff'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

enum StaffRole {
  cashier,
  manager,
  admin,
  custom;

  static StaffRole fromName(String? name) {
    return StaffRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => StaffRole.cashier,
    );
  }
}

class OwnerProfile {
  const OwnerProfile({
    this.name = '',
    this.phone = '',
    this.email = '',
  });

  final String name;
  final String phone;
  final String email;

  OwnerProfile copyWith({String? name, String? phone, String? email}) {
    return OwnerProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty;
}
