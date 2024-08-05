import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:project_base/config/load_env.dart';

class StmpService {
  static final StmpService _instance = StmpService._init();
  late final Env _env;

  StmpService._init() {
    _env = Env();
  }

  factory StmpService() => _instance;

  Future<void> sendMessage(
      String userMail, String newPassword, String username) async {
    final smtpServer = gmail(
      _env.envConfig.smtpMail,
      _env.envConfig.smtpPassword,
    );

    // Read HTML content from file
    final htmlContent =
        await File('lib/html//password_reset_email.html').readAsString();

    // Replace placeholders with actual values
    final htmlMessage = htmlContent
        .replaceAll('{{new_password}}', newPassword)
        .replaceAll('{{username}}', username);

    final message = Message()
      ..from = Address(_env.envConfig.smtpMail, 'Cloud Mining')
      ..recipients.add(userMail)
      ..subject = 'Password Reset'
      ..html = htmlMessage;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
