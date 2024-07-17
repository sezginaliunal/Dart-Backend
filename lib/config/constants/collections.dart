enum CollectionPath {
  users,
  transactions,
  tokens,
}

extension CollectionPathExtension on CollectionPath {
  String get rawValue {
    switch (this) {
      case CollectionPath.users:
        return 'users';
      case CollectionPath.transactions:
        return 'transactions';
      case CollectionPath.tokens:
        return 'tokens';
    }
  }
}
