import 'dart:io';

import 'package:asamurat/cli/menu/init.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/services/auth.dart';
import 'package:asamurat/utils/helpers.dart';
import 'package:asamurat/utils/json.dart';

const int maxRetries = 3;

class InitLogin extends State {
  int _errCount = 0;

  late String username;
  late String password;

  InitLogin() {
    isReady = true;
  }

  String _askUsername() {
    setCursor(7, 15);
    String? readUsername = stdin.readLineSync();

    if (readUsername == null) return "";
    return readUsername;
  }

  String _askPassword() {
    setCursor(9, 15);
    stdin.echoMode = false;
    String? readPassword = stdin.readLineSync();
    stdin.echoMode = true;
    stdout.writeln();

    if (readPassword == null) return "";
    return readPassword;
  }

  bool _userLogin(AuthService auth) {
    if (_errCount < maxRetries) {
      printMenu();

      username = _askUsername();
      password = _askPassword();
      try {
        auth.login(username: username, password: password);
        return false;
      } catch (e) {
        _errCount++;
        setCursor(11, 0);
        print(colorizeText("┌──────────────────────────┐", TextColor.red));
        print(colorizeText("│  $e   │", TextColor.red));
        print(colorizeText("└──────────────────────────┘", TextColor.red));
        sleep(const Duration(seconds: 1));
        return _userLogin(auth);
      }
    }

    clear();
    return true;
  }

  void printMenu() {
    clear();
    print("┌──────────────────────────┐");
    print("│ Aplikasi Manajemen Surat │");
    print("└──────────────────────────┘");
    print("┌──────────────────────────┐");
    print("│ Login                    │");
    print("├──────────────────────────┤");
    print("│ - Username:              │");
    print("├──────────────────────────┤");
    print("│ - Password:              │");
    print("└──────────────────────────┘");
    print("        ┌─────────┐");
    print("        │ by ${colorizeText('2048', TextColor.cyan)} │");
    print("        └─────────┘");
  }

  @override
  void handler({required Cli context}) {
    final users = jsonToList('${Directory.current.path}/data/user.json');
    final authService = AuthService(users);

    (_userLogin(authService))
        ? exit(-1)
        : context.state = InitMenu(previous: this);
  }
}
