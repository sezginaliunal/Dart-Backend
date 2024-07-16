class ResponseHandler<T> {
  final T? data;
  final bool success;
  final ResponseMessage message;

  ResponseHandler({
    this.data,
    this.success = false,
    this.message = ResponseMessage.unexpectedError,
  });

  Map<String, dynamic> toJson() {
    return {'data': data, 'success': success, 'message': message.rawValue};
  }
}

enum ResponseMessage {
  userAdded,
  userDeleted,
  userUpdated,
  userNotFound,
  userAlreadyExists,
  operationSuccessful,
  operationFailed,
  unauthorizedAccess,
  invalidRequest,
  requiredField,
  serverError,
  connectionError,
  timeoutError,
  dataNotFound,
  dataAlreadyExists,
  resourceNotFound,
  resourceAlreadyExists,
  insufficientPermissions,
  invalidCredentials,
  expiredToken,
  tokenInvalid,
  requestCancelled,
  unexpectedError,
  maintenanceMode,
  quotaExceeded,
  fileTooLarge,
  fileFormatUnsupported,
  networkUnavailable,
  paymentFailed,
  orderPlaced,
  orderCancelled,
  orderCompleted,
  itemAdded,
  itemDeleted,
  itemUpdated,
  itemNotFound,
  itemOutOfStock,
  itemUnavailable,
  itemPurchased,
  itemSoldOut,
  accountCreated,
  accountUpdated,
  accountDeleted,
  accountNotFound,
  accountDisabled,
  accountEnabled,
  subscriptionStarted,
  subscriptionCancelled,
  subscriptionExpired,
  subscriptionRenewed,
  subscriptionNotFound,
}

extension ResponseMessageExtension on ResponseMessage {
  String get rawValue {
    switch (this) {
      case ResponseMessage.userAdded:
        return 'User added successfully.';
      case ResponseMessage.userDeleted:
        return 'User deleted successfully.';
      case ResponseMessage.userUpdated:
        return 'User updated successfully.';
      case ResponseMessage.userNotFound:
        return 'User not found.';
      case ResponseMessage.userAlreadyExists:
        return 'User already exists.';
      case ResponseMessage.operationSuccessful:
        return 'Operation successful.';
      case ResponseMessage.operationFailed:
        return 'Operation failed.';
      case ResponseMessage.unauthorizedAccess:
        return 'Unauthorized access.';
      case ResponseMessage.invalidRequest:
        return 'Invalid request.';
      case ResponseMessage.serverError:
        return 'Server error occurred.';
      case ResponseMessage.connectionError:
        return 'Connection error occurred.';
      case ResponseMessage.timeoutError:
        return 'Request timed out.';
      case ResponseMessage.dataNotFound:
        return 'Data not found.';
      case ResponseMessage.dataAlreadyExists:
        return 'Data already exists.';
      case ResponseMessage.resourceNotFound:
        return 'Resource not found.';
      case ResponseMessage.resourceAlreadyExists:
        return 'Resource already exists.';
      case ResponseMessage.insufficientPermissions:
        return 'Insufficient permissions.';
      case ResponseMessage.invalidCredentials:
        return 'Invalid credentials.';
      case ResponseMessage.expiredToken:
        return 'Token has expired.';
      case ResponseMessage.tokenInvalid:
        return 'Invalid token.';
      case ResponseMessage.requestCancelled:
        return 'Request cancelled.';
      case ResponseMessage.unexpectedError:
        return 'An unexpected error occurred.';
      case ResponseMessage.maintenanceMode:
        return 'System under maintenance.';
      case ResponseMessage.quotaExceeded:
        return 'Quota exceeded.';
      case ResponseMessage.fileTooLarge:
        return 'File size exceeds limit.';
      case ResponseMessage.fileFormatUnsupported:
        return 'File format not supported.';
      case ResponseMessage.networkUnavailable:
        return 'Network unavailable.';
      case ResponseMessage.paymentFailed:
        return 'Payment failed.';
      case ResponseMessage.orderPlaced:
        return 'Order placed successfully.';
      case ResponseMessage.orderCancelled:
        return 'Order cancelled successfully.';
      case ResponseMessage.orderCompleted:
        return 'Order completed successfully.';
      case ResponseMessage.itemAdded:
        return 'Item added successfully.';
      case ResponseMessage.itemDeleted:
        return 'Item deleted successfully.';
      case ResponseMessage.itemUpdated:
        return 'Item updated successfully.';
      case ResponseMessage.itemNotFound:
        return 'Item not found.';
      case ResponseMessage.itemOutOfStock:
        return 'Item is out of stock.';
      case ResponseMessage.itemUnavailable:
        return 'Item is currently unavailable.';
      case ResponseMessage.itemPurchased:
        return 'Item purchased successfully.';
      case ResponseMessage.itemSoldOut:
        return 'Item is sold out.';
      case ResponseMessage.accountCreated:
        return 'Account created successfully.';
      case ResponseMessage.accountUpdated:
        return 'Account updated successfully.';
      case ResponseMessage.accountDeleted:
        return 'Account deleted successfully.';
      case ResponseMessage.accountNotFound:
        return 'Account not found.';
      case ResponseMessage.accountDisabled:
        return 'Account is disabled.';
      case ResponseMessage.accountEnabled:
        return 'Account is enabled.';
      case ResponseMessage.subscriptionStarted:
        return 'Subscription started successfully.';
      case ResponseMessage.subscriptionCancelled:
        return 'Subscription cancelled successfully.';
      case ResponseMessage.subscriptionExpired:
        return 'Subscription has expired.';
      case ResponseMessage.subscriptionRenewed:
        return 'Subscription renewed successfully.';
      case ResponseMessage.subscriptionNotFound:
        return 'Subscription not found.';
      case ResponseMessage.requiredField:
        return 'Required must be filled';
      default:
        return 'Undefined message.';
    }
  }
}
