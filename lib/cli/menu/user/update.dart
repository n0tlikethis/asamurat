import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/user.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

String emptyWarning = "Data harus diisi! ";
String invalidFormatWarning = "Format salah! ";

late ServiceUserPersistent userList;

class UserUpdate extends Menu {
  late User _user;

  int _maxWidth = 100;
  int _inputPos = 14;

  late String nama;
  late String username;
  late String password;
  late Role role;

  UserUpdate({required State previous, required ServiceUserPersistent service, required User user}) {
    super.previous = previous;
    userList = service;
    _user = user;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();

    nama = _askNama();
    username = _askUsername();
    password = _askPassword();
    role = _askRole();

    if (_askConfirmation()) {
      try {
        updateUser();
        print("success");
      } catch (e) {
        print("failed");
      }
    }

    context.state = previous!;
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌──────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ User > Edit User │");
    print("└──────────────────────────┘ └──────────────────┘");

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
    print("┌───────────────────┬──────────────────────┬───────────┐");
    print("│ Simpan perubahan? │ [Y] Simpan (default) │ [N] Batal │");
    print("└───────────────────┴──────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(19, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void updateUser() {
    User user = User(
        id: _user.id,
        nama: nama,
        username: username,
        password: password,
        role: role);
    userList.update(user: user);
  }

  String _askNama() {
    int inPos = 7;
    setCursor(inPos, _inputPos);
    String? readNama = stdin.readLineSync();

    if (readNama == null || readNama.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_user.nama);
      return _user.nama;
    }

    return readNama;
  }

  String _askUsername() {
    int inPos = 9;
    setCursor(inPos, _inputPos);
    String? readUsername = stdin.readLineSync();

    if (readUsername == null || readUsername.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_user.username);
      return _user.username;
    }

    return readUsername;
  }

  String _askPassword() {
    int inPos = 11;
    setCursor(inPos, _inputPos);
    String? readPassword = stdin.readLineSync();

    if (readPassword == null || readPassword.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_user.password);
      return _user.password;
    }

    return readPassword;
  }

  Role _askRole() {
    int inPos = 13;
    setCursor(inPos, _inputPos);
    String? readRole = stdin.readLineSync();

    if (readRole == null || readRole.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_user.role.index + 1);
      return _user.role;
    }

    if (_checkInputRole(readRole, inPos)) return _askRole();

    int roleI = int.parse(readRole) - 1;

    return Role.values[roleI];
  }

  bool _checkInputRole(String? input, int pos) {
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
