extension StringValidators on String {
  bool get isValidEmail {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$',
    );
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    );
    return passwordRegExp.hasMatch(this);
  }
}
