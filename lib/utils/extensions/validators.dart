extension StringValidators on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$',
    );
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final strongPasswordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.,])[A-Za-z\d@$!%*?&.,]{8,}$',
    );
    return strongPasswordRegex.hasMatch(this);
  }
}
