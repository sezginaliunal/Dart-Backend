import 'dart:convert';
import 'package:crypto/crypto.dart';

extension StringHashing on String {
  /// String'i SHA-256 algoritması ile hashler ve Base64 olarak döner
  String toSha256() {
    var bytes = utf8.encode(this);
    var digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// Orijinal string'in hashlenmiş hali ile verilen hash'i karşılaştırır
  bool verifySha256(String hashedValue) {
    return toSha256() == hashedValue;
  }
}

// void main() {
//   String password = "mySecurePassword";
//   String hashedPassword = password.toSha256();

//   print("Hashed Password: $hashedPassword");

//   bool isVerified = password.verifySha256(hashedPassword);
//   print("Password Verified: $isVerified");
// }
