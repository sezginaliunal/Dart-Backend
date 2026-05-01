enum UserStatus {
  active(value: 1),
  inactive(value: 2),
  banned(value: 3),
  pendingVerification(value: 4),
  deleted(value: 5);

  final int value;

  const UserStatus({required this.value});

  factory UserStatus.fromValue(int value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid UserStatus value: $value'),
    );
  }

  bool get isActive => this == UserStatus.active;
  bool get isInactive => this == UserStatus.inactive;
  bool get isBanned => this == UserStatus.banned;
  bool get isPendingVerification => this == UserStatus.pendingVerification;
  bool get isDeleted => this == UserStatus.deleted;

  /// Kullanıcının sisteme erişimine izin verilip verilmediğini kontrol eder.
  bool get canAccess => isActive || isPendingVerification;
}

enum UserRole {
  admin(value: 1),
  moderator(value: 2),
  customer(value: 3),
  guest(value: 4);

  final int value;

  const UserRole({required this.value});

  factory UserRole.fromValue(int value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid UserRole value: $value'),
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isModerator => this == UserRole.moderator;
  bool get isCustomer => this == UserRole.customer;
  bool get isGuest => this == UserRole.guest;

  /// Admin ve moderatör yönetici sayılır.
  bool get isStaff => isAdmin || isModerator;
}
