enum AuthType {
  email(value: 1),
  google(value: 2),
  apple(value: 3),
  facebook(value: 4);

  final int value;

  const AuthType({required this.value});
  factory AuthType.fromValue(int value) {
    return AuthType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AuthType value: $value'),
    );
  }

  bool get isEmail => this == AuthType.email;
  bool get isGoogle => this == AuthType.google;
  bool get isApple => this == AuthType.apple;
  bool get isFacebook => this == AuthType.facebook;
}
