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
  internalError,
  isExist,
  insufficientFunds,
  wantWithdraw,
  belowMinimumWithdraw,
  belowAccountMinimumWithdraw,
  accountBanned,
  accountSuspended,
  accountDeleted,
  accountInactive,
  expired,
  tooManyRequest,
  ticketIsExist,
  notUpdated,
  giftboxExpired,
  referenceNotFound
}

extension ResponseMessagesExtension on ResponseMessages {
  String get message {
    switch (this) {
      case ResponseMessages.invalidEmail:
        return 'Invalid email format.';
      case ResponseMessages.invalidPassword:
        return 'Password must be at least 8 characters long and contain both a letter and a number.';
      case ResponseMessages.existUser:
        return 'A user is already registered with this email or device.';
      case ResponseMessages.successRegister:
        return 'User successfully registered.';
      case ResponseMessages.suspendUser:
        return 'Account is suspicious or inactive.';
      case ResponseMessages.wrongPassword:
        return 'Incorrect password.';
      case ResponseMessages.userNotFound:
        return 'User not found.';
      case ResponseMessages.successLogin:
        return 'Login successful.';
      case ResponseMessages.successLogout:
        return 'Logged out successfully.';
      case ResponseMessages.updateToken:
        return 'Token updated.';
      case ResponseMessages.somethingError:
        return 'An error occurred.';
      case ResponseMessages.unauthorized:
        return 'Unauthorized action.';
      case ResponseMessages.invalidHeader:
        return 'Invalid header.';
      case ResponseMessages.invalidToken:
        return 'Invalid token.';
      case ResponseMessages.invalidBody:
        return 'Body cannot be empty.';
      case ResponseMessages.notFound:
        return 'Not found.';
      case ResponseMessages.internalError:
        return 'Server error.';
      case ResponseMessages.isExist:
        return 'Data already exists.';
      case ResponseMessages.insufficientFunds:
        return 'You do not have enough balance to withdraw this amount.';
      case ResponseMessages.wantWithdraw:
        return 'The amount you want to withdraw is not in your account.';
      case ResponseMessages.belowMinimumWithdraw:
        return 'The amount you want to withdraw is below the minimum withdrawal limit.';
      case ResponseMessages.belowAccountMinimumWithdraw:
        return 'Your account balance is below the minimum withdrawal limit.';
      case ResponseMessages.accountBanned:
        return 'Account is banned';
      case ResponseMessages.accountSuspended:
        return 'Account is suspended';
      case ResponseMessages.accountDeleted:
        return 'Account is deleted';
      case ResponseMessages.accountInactive:
        return 'Account is inactive';
      case ResponseMessages.expired:
        return 'Expired';
      case ResponseMessages.tooManyRequest:
        return 'Too many requests. Try again later.';
      case ResponseMessages.ticketIsExist:
        return 'Ticket is exist';
      case ResponseMessages.notUpdated:
        return 'Not Updated';
      case ResponseMessages.giftboxExpired:
        return 'Giftbox has not expired yet';
      case ResponseMessages.referenceNotFound:
        return 'Reference not found';
    }
  }
}
