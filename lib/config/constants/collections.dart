enum CollectionPath { users }

extension CollectionPathExtension on CollectionPath {
  String get rawValue {
    switch (this) {
      case CollectionPath.users:
        return 'users';
    }
  }
}
