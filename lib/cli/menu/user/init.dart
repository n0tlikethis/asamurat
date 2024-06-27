import 'dart:io';

import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/user/create.dart';
import 'package:asamurat/cli/menu/user/list.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

enum Option { undefined, read, create, update, delete, back }

late ServiceUserPersistent userList;

class UserMenu extends Menu {
  Option option = Option.undefined;

  int _inputPos = 15;

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.read, text: "Daftar User"),
    OptionsMenu(option: Option.create, text: "Tambah User"),
    OptionsMenu(option: Option.update, text: "Edit User"),
    OptionsMenu(option: Option.delete, text: "Hapus User"),
    OptionsMenu(option: Option.back, text: "Kembali"),
  ];

  UserMenu({required State previous, required ServiceUserPersistent service}) {
    super.previous = previous;
    userList = service;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    if (!_handleOption()) {
      clear();
      exit(-1);
    } else {
      switch (option) {
        case Option.create:
          context.state = UserCreate(previous: this, service: userList);
          break;
        case Option.read:
          context.state = UserList(previous: this, action: Action.read, service: userList);
          break;
        case Option.update:
          context.state = UserList(previous: this, action: Action.update, service: userList);
          break;
        case Option.delete:
          context.state = UserList(previous: this, action: Action.delete, service: userList);
          break;
        case Option.back:
          context.state = previous!;
          break;
        default:
          context.state = this;
          break;
      }
    }
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌──────┐");
    print("│ Aplikasi Manajemen Surat │ │ User │");
    print("└──────────────────────────┘ └──────┘");

    printMenu(options, breakPos: Option.delete.index);

    print("┌──────────────────────────┐");
    print("│ Pilih menu:              │");
    print("└──────────────────────────┘");
  }

  // Gets [option] as Option type
  Option _getCastOption(int option) {
    try {
      return options[option - 1].option;
    } catch (err) {
      return Option.undefined;
    }
  }

  ///// Returns true if the user selected a correct answer and handles wrong options
  bool _handleOption() {
    showMenu();
    setCursor(_inputPos, 15);

    option = _getCastOption(
        checkOption(option: stdin.readLineSync(), min: 1, max: options.length));

    if (option == Option.undefined) {
      setCursor(_inputPos - 1, 0);
      print(colorizeText("┌──────────────────────────┐", TextColor.red));
      print(colorizeText("│ Input salah!             │", TextColor.red));
      print(colorizeText("└──────────────────────────┘", TextColor.red));
      sleep(const Duration(seconds: 1));
      return _handleOption();
    }

    return true;
  }
}
