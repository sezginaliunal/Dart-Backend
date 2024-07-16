enum CollectionPath {
  users,
  transactions,
}

extension CollectionPathExtension on CollectionPath {
  String get rawValue {
    switch (this) {
      case CollectionPath.users:
        return 'users';
      case CollectionPath.transactions:
        return 'transactions';
    }
  }
}
