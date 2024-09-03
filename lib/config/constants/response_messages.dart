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
        return 'Geçersiz email formatı';
      case ResponseMessages.invalidPassword:
        return 'Şifre en az 8 karakter uzunluğunda ve bir harf ile bir rakam içermelidir';
      case ResponseMessages.existUser:
        return 'Bu emaile kayıtlı kullanıcı var';
      case ResponseMessages.successRegister:
        return 'Kullanıcı kayıt oldu';
      case ResponseMessages.suspendUser:
        return 'Hesap şüpheli veya aktif değil';
      case ResponseMessages.wrongPassword:
        return 'Şifre yanlış';
      case ResponseMessages.userNotFound:
        return 'Kullanıcı bulunamadı';
      case ResponseMessages.successLogin:
        return 'Giriş başarılı';
      case ResponseMessages.successLogout:
        return 'Çıkış yapıldı';
      case ResponseMessages.updateToken:
        return 'Token güncellendi';
      case ResponseMessages.somethingError:
        return 'Bir hata oluştu';
      case ResponseMessages.unauthorized:
        return 'Yetkisiz işlem';
      case ResponseMessages.invalidHeader:
        return 'Geçersiz header';
      case ResponseMessages.invalidToken:
        return 'Geçersiz token';
      case ResponseMessages.invalidBody:
        return 'Body boş olamaz';
      case ResponseMessages.notFound:
        return 'Bulunamadı';
      case ResponseMessages.internalError:
        return 'Sunucu hatası';
    }
  }
}
