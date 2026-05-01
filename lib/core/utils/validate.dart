class ValidateKeys {
  static const valEmailRequired = 'Email gerekli';
  static const valInvalidEmail = 'Email formatı hatalı';
  static const valPasswordRequired = 'Şifre gerekli';
  static const valPasswordMinLength = 'Şifre en az karakter olmalı';
  static const valFieldRequired = 'Alan zorunlu';
  static const valInvalidNumber = 'Geçersiz sayı';
  static const valPhoneRequired = 'Telefon gerekli';
  static const valInvalidPhone = 'Telefon geçersiz';
  static const valInvalidUrl = 'URL geçersiz';
}

sealed class ValidationError {
  const ValidationError();

  String toMessage() => switch (this) {
    EmailRequired() => ValidateKeys.valEmailRequired,
    InvalidEmail() => ValidateKeys.valInvalidEmail,
    PasswordRequired() => ValidateKeys.valPasswordRequired,
    PasswordMinLength(minLength: final m) =>
      '${ValidateKeys.valPasswordMinLength} ($m)',
    FieldRequired() => ValidateKeys.valFieldRequired,
    InvalidNumber() => ValidateKeys.valInvalidNumber,
    PhoneRequired() => ValidateKeys.valPhoneRequired,
    InvalidPhone() => ValidateKeys.valInvalidPhone,
    InvalidUrl() => ValidateKeys.valInvalidUrl,
  };

  String toBackendMessage() => switch (this) {
    EmailRequired() => 'Email gerekli',
    InvalidEmail() => 'Email formatı hatalı',
    PasswordRequired() => 'Şifre gerekli',
    PasswordMinLength(minLength: final m) => 'Şifre en az $m karakter olmalı',
    FieldRequired() => 'Alan zorunlu',
    InvalidNumber() => 'Geçersiz sayı',
    PhoneRequired() => 'Telefon gerekli',
    InvalidPhone() => 'Telefon geçersiz',
    InvalidUrl() => 'URL geçersiz',
  };
}

class EmailRequired extends ValidationError {
  const EmailRequired();
}

class InvalidEmail extends ValidationError {
  const InvalidEmail();
}

class PasswordRequired extends ValidationError {
  const PasswordRequired();
}

class PasswordMinLength extends ValidationError {
  final int minLength;
  const PasswordMinLength(this.minLength);
}

class FieldRequired extends ValidationError {
  const FieldRequired();
}

class InvalidNumber extends ValidationError {
  const InvalidNumber();
}

class PhoneRequired extends ValidationError {
  const PhoneRequired();
}

class InvalidPhone extends ValidationError {
  const InvalidPhone();
}

class InvalidUrl extends ValidationError {
  const InvalidUrl();
}

class Validators {
  static ValidationError? validateEmail(String? input) {
    final value = input?.trim();

    if (value == null || value.isEmpty) {
      return const EmailRequired();
    }
    if (!value.isEmail) {
      return const InvalidEmail();
    }
    return null;
  }

  static ValidationError? validatePassword(String? input, {int minLength = 8}) {
    final value = input?.trim();

    if (value == null || value.isEmpty) {
      return const PasswordRequired();
    }
    if (value.length < minLength) {
      return PasswordMinLength(minLength);
    }
    return null;
  }

  static ValidationError? validateNull(String? input) {
    final value = input?.trim();
    return (value == null || value.isEmpty) ? const FieldRequired() : null;
  }

  static ValidationError? validateNumeric(String? input) {
    final value = input?.trim();

    if (value == null || value.isEmpty) {
      return const FieldRequired();
    }
    if (!value.isNumeric) {
      return const InvalidNumber();
    }
    return null;
  }

  static ValidationError? validatePhoneNumber(String? input) {
    final value = input?.trim();

    if (value == null || value.isEmpty) {
      return const PhoneRequired();
    }
    if (!value.isPhoneNumber) {
      return const InvalidPhone();
    }
    return null;
  }

  static ValidationError? validateHttp(String? input) {
    final value = input?.trim();

    if (value == null || value.isEmpty) {
      return const FieldRequired();
    }
    if (!(value.startsWith('http://') || value.startsWith('https://'))) {
      return const InvalidUrl();
    }
    return null;
  }
}

extension StringValidationX on String {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static final RegExp _numericRegex = RegExp(r'^\d+$');

  /// Türkiye ve genel uluslararası formatları kapsayan basit telefon regex’i
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  bool get isEmail {
    return _emailRegex.hasMatch(this);
  }

  bool get isNumeric {
    return _numericRegex.hasMatch(this);
  }

  bool get isPhoneNumber {
    final value = trim();
    return _phoneRegex.hasMatch(value);
  }
}
