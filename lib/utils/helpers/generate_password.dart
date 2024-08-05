import 'dart:math';

class PasswordGenerator {
  // Bu metod, belirli bir uzunlukta rastgele bir şifre oluşturur.
  static String generatePassword({int length = 12}) {
    const String upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String digits = '0123456789';
    const String specialChars = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    final Random random = Random();
    final String allChars =
        upperCaseChars + lowerCaseChars + digits + specialChars;

    String generateRandomString(String chars, int length) {
      return List.generate(
          length, (index) => chars[random.nextInt(chars.length)]).join();
    }

    // Şifreye rastgele büyük harf, küçük harf, rakam ve özel karakter ekleyelim
    String password = generateRandomString(upperCaseChars, 2) +
        generateRandomString(lowerCaseChars, 2);

    // Kalan karakterleri karışık olarak ekleyelim
    password += generateRandomString(allChars, length - password.length);
    print(password);
    // Şifreyi karıştır
    return password;
  }
}
