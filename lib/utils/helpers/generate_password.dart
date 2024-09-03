import 'dart:math';

class PasswordGenerator {
  // Bu metod, belirli bir uzunlukta rastgele bir şifre oluşturur.
  static String generatePassword({int length = 12}) {
    const upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const specialChars = r'!@#$%^&*()-_=+[]{}|;:,.<>?';

    final random = Random();
    const allChars = upperCaseChars + lowerCaseChars + digits + specialChars;

    String generateRandomString(String chars, int length) {
      return List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    // Şifreye rastgele büyük harf, küçük harf, rakam ve özel karakter ekleyelim
    var password = generateRandomString(upperCaseChars, 2) +
        generateRandomString(lowerCaseChars, 2);

    // Kalan karakterleri karışık olarak ekleyelim
    return password += generateRandomString(allChars, length - password.length);
  }
}
