import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/user.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

const int maxRetries = 3;
String emptyWarning = "Data harus diisi! ";
String invalidFormatWarning = "Input salah! ";

late ServiceUserPersistent userList;

class UserCreate extends Menu {
  int _errorCount = 0;
  int _maxWidth = 100;
  int _inputPos = 14;

  late int id;
  late String nama;
  late String username;
  late String password;
  late Role role;

  UserCreate({required State previous, required ServiceUserPersistent service}) {
    super.previous = previous;
    userList = service;
    isReady = true;

    id = userList.lastId + 1;
  }

  @override
  void handler({required Cli context}) {
    showMenu();
    nama = _checkRetries(_askNama(), _askNama);

    if (nama.isNotEmpty) {
      username = _askUsername();
      password = _askPassword();
      role = _askRole();

      if (_askConfirmation()) {
        try {
          saveUser();
          print("success");
        } catch (e) {
          print("failed");
        }
      }
    }

    context.state = previous!;
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ User > Tambah User │");
    print("└──────────────────────────┘ └────────────────────┘");

    showDetails();
  }

  void showDetails() {
    print("┌────────────${"─" * _maxWidth}─┐");
    print("│ ${"Detail User".padRight(_maxWidth + 11)} │");
    print("├──────────┬─${"─" * _maxWidth}─┤");
    print("│ Nama     │ ${" " * _maxWidth} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Username │ ${" " * _maxWidth} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Password │ ${" " * _maxWidth} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Role     │ ${" " * (_maxWidth - 40)} [ 1: admin, 2: headmaster, 3: officer ] │");
    print("└──────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(15, 0);
    print("┌──────────────┬──────────────────────┬───────────┐");
    print("│ Simpan user? │ [Y] Simpan (default) │ [N] Batal │");
    print("└──────────────┴──────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(19, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void saveUser() {
    User user = User(
        id: id,
        nama: nama,
        username: username,
        password: password,
        role: role);
    userList.create(user: user);
  }

  String _askNama() {
    int inPos = 7;
    setCursor(inPos, _inputPos);
    String? readNama = stdin.readLineSync();

    if (_checkInputNull(readNama, inPos)) null;

    return readNama!;
  }

  String _askUsername() {
    int inPos = 9;
    setCursor(inPos, _inputPos);
    String? readUsername = stdin.readLineSync();

    if (_checkInputNull(readUsername, inPos)) return _askUsername();

    return readUsername!;
  }

  String _askPassword() {
    int inPos = 11;
    setCursor(inPos, _inputPos);
    String? readPassword = stdin.readLineSync();

    if (_checkInputNull(readPassword, inPos)) return _askPassword();

    return readPassword!;
  }

  Role _askRole() {
    int inPos = 13;
    setCursor(inPos, _inputPos);
    String? readRole = stdin.readLineSync();

    if (_checkInputRole(readRole, inPos)) return _askRole();

    int roleI = int.parse(readRole!) - 1;

    return Role.values[roleI];
  }

  String _checkRetries(String result, Function cb) {
    if (result.isEmpty) {
      if (_errorCount < maxRetries - 1) {
        _errorCount++;
        return _checkRetries(cb(), cb);
      }

      return "";
    }

    return result;
  }

  bool _checkInputNull(String? input, int pos) {
    if (input == null || input.isEmpty) {
      setCursor(pos, _inputPos);
      stdout.write(colorizeText(emptyWarning, TextColor.red));
      sleep(const Duration(seconds: 1));

      setCursor(pos, _inputPos);
      stdout.write(" " * emptyWarning.length);

      return true;
    } else {
      return false;
    }
  }

  bool _checkInputRole(String? input, int pos) {
    if (_checkInputNull(input, pos)) return true;

    List<Role> roleList = Role.values;
    int? roleI = int.tryParse(input!);

    if (roleI != null && roleI > 0 && roleI <= roleList.length) {
      return false;
    } else {
      setCursor(pos, _inputPos);
      stdout.write(colorizeText(invalidFormatWarning, TextColor.red));
      sleep(const Duration(seconds: 1));

      setCursor(pos, _inputPos);
      stdout.write(" " * invalidFormatWarning.length);

      return true;
    }
  }
}
