import 'package:project_base/model/user.dart';

final class UserMock {
  User get onlyOneUser => User(
        username: 'username',
        email: 'email@hotmail.com',
        password: '12345678Aa.',
      );
  List<User> get users => [
        User(
          username: 'username1',
          email: 'email1@hotmail.com',
          password: '12345678Aa.',
        ),
        User(
          username: 'username2',
          email: 'email2@hotmail.com',
          password: '12345678Aa.',
        ),
      ];
}
