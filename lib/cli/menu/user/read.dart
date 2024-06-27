import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/user.dart';
import 'package:asamurat/utils/helpers.dart';

class UserRead extends Menu {
  late User _user;

  int _maxWidth = 100;

  UserRead({required State previous, required User user}) {
    super.previous = previous;
    _user = user;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();

    _askConfirmation();
    
    context.state = previous!;
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ User > Detail User │");
    print("└──────────────────────────┘ └────────────────────┘");

    showDetails();

    print("┌─────────────┐");
    print("│ [0] Kembali │");
    print("└─────────────┘");

    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");
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
    print("┌───────────────────────┐");
    print("│ [0] Kembali (default) │");
    print("└───────────────────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(19, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() == '0';
  }
}
