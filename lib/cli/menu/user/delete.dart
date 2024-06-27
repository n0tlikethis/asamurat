import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/user.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

late ServiceUserPersistent userList;

class UserDelete extends Menu {
  late User _user;

  int _maxWidth = 100;

  late int id;

  UserDelete({required State previous, required ServiceUserPersistent service, required User user}) {
    super.previous = previous;
    userList = service;
    _user = user;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();

    if (_askConfirmation()) {
      try {
        deleteUser();
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

    print("┌──────────────────────────┐ ┌───────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ User > Hapus User │");
    print("└──────────────────────────┘ └───────────────────┘");

    showDetails();
  }

  void showDetails() {
    print("┌────────────${"─" * _maxWidth}─┐");
    print("│ ${"Detail User".padRight(_maxWidth + 11)} │");
    print("├──────────┬─${"─" * _maxWidth}─┤");
    print("│ Nama     │ ${_user.nama.padRight(_maxWidth)} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Username │ ${_user.username.padRight(_maxWidth)} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Password │ ${_user.password.padRight(_maxWidth)} │");
    print("├──────────┼─${"─" * _maxWidth}─┤");
    print("│ Role     │ ${_user.role.name.padRight(_maxWidth)} │");
    print("└──────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(15, 0);
    print("┌─────────────┬─────────────────────┬───────────┐");
    print("│ Hapus user? │ [Y] Hapus (default) │ [N] Batal │");
    print("└─────────────┴─────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(19, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void deleteUser() {
    userList.delete(user: _user);
  }
}
