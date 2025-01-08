import 'package:project_base/utils/extensions/validators.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Email Validator', () {
    expect('sezgin@hotmail.com'.isValidEmail, true);
    expect('sezginhotmail.com'.isValidEmail, false);
  });
  test('Password Validator', () {
    expect('12345678'.isValidPassword, false);
    expect('12345678Aa.'.isValidPassword, true);
  });
}
