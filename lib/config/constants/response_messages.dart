enum ResponseMessages {
  invalidEmail,
  invalidPassword,
  wrongPassword,
  existUser,
  userNotFound,
  successRegister,
  successLogin,
  successLogout,
  suspendUser,
  updateToken,
  somethingError,
  unauthorized,
  invalidHeader,
  invalidToken,
  invalidBody,
  notFound,
  internalError
}

extension ResponseMessagesExtension on ResponseMessages {
  String get message {
    switch (this) {
      case ResponseMessages.invalidEmail:
        return 'Invalid email format';
      case ResponseMessages.invalidPassword:
        return '''
Password must be at least 8 characters
        long and contain both a letter and a number''';
      case ResponseMessages.existUser:
        return 'A user is already registered with this email';
      case ResponseMessages.successRegister:
        return 'User successfully registered';
      case ResponseMessages.suspendUser:
        return 'Account is suspicious or inactive';
      case ResponseMessages.wrongPassword:
        return 'Incorrect password';
      case ResponseMessages.userNotFound:
        return 'User not found';
      case ResponseMessages.successLogin:
        return 'Login successful';
      case ResponseMessages.successLogout:
        return 'Logged out successfully';
      case ResponseMessages.updateToken:
        return 'Token updated';
      case ResponseMessages.somethingError:
        return 'An error occurred';
      case ResponseMessages.unauthorized:
        return 'Unauthorized action';
      case ResponseMessages.invalidHeader:
        return 'Invalid header';
      case ResponseMessages.invalidToken:
        return 'Invalid token';
      case ResponseMessages.invalidBody:
        return 'Body cannot be empty';
      case ResponseMessages.notFound:
        return 'Not found';
      case ResponseMessages.internalError:
        return 'Server error';
    }
  }
}
