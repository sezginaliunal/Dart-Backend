enum AccountStatus {
  active,
  inactive,
  suspended,
  pending,
  banned,
  deleted,
  underReview, // New status for accounts being reviewed
  expired, // New status for expired accounts
  locked; // New status for accounts that are locked due to failed attempts

  int get value => index; // Enum sırasını int olarak döndüren getter
}

enum AccountRole {
  user, // Regular user with basic access
  supervisor, // User with supervisor privileges
  admin, // Administrator with full access
  guest,
  moderator,
  owner;

  int get value => index; // Enum sırasını int olarak döndüren getter

// Yetkili rolleri kontrol eden metod
  bool get isPrivileged =>
      this == AccountRole.owner ||
      this == AccountRole.supervisor ||
      this == AccountRole.admin;
}

AccountStatus checkAccountStatus(int accountStatusValue) {
  return AccountStatus.values.firstWhere(
    (status) => status.value == accountStatusValue,
    orElse: () => AccountStatus.active,
  );
}

AccountRole checkAccountRole(int accountRoleValue) {
  return AccountRole.values.firstWhere(
    (role) => role.value == accountRoleValue,
    orElse: () => AccountRole.user,
  );
}
