enum CollectionPath { users, token }

extension CollectionPathExtension on CollectionPath {
  String get rawValue {
    switch (this) {
      case CollectionPath.users:
        return 'users';
      case CollectionPath.token:
        return 'token';
    }
  }
}
