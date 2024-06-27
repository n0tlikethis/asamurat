import 'dart:io';

import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/surat/init.dart';
import 'package:asamurat/cli/menu/user/init.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/services/auth.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

final suratJson = '${Directory.current.path}/data/surat.json';
final suratList = ServiceSuratPersistent.fromJsonList(filePath: suratJson);
final userJson = '${Directory.current.path}/data/user.json';
final userList = ServiceUserPersistent.fromJsonList(filePath: userJson);

enum Option { undefined, manageUser, suratMasuk, suratKeluar, logout, exit }

class InitMenu extends Menu {
  Option option = Option.undefined;

  int _inputPos = 14;

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.suratMasuk, text: "Data Surat Masuk"),
    OptionsMenu(option: Option.suratKeluar, text: "Data Surat Keluar"),
    OptionsMenu(option: Option.logout, text: "Logout"),
    OptionsMenu(option: Option.exit, text: "Exit"),
  ];

  void _checkUserRole() {
    if (AuthService.loggedUser.role == Role.admin) {
      _inputPos = 15;
      options.insert(
          0, OptionsMenu(option: Option.manageUser, text: "Data User"));
    }
  }

  InitMenu({required State previous}) {
    super.previous = previous;
    _checkUserRole();
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    if (!_handleOption() || option == Option.exit) {
      clear();
      exit(-1);
    } else {
      switch (option) {
        case Option.manageUser:
          context.state = UserMenu(previous: this, service: userList);
          break;
        case Option.suratMasuk:
          context.state = SuratMenu(previous: this, jenis: Jenis.masuk, service: suratList);
          break;
        case Option.suratKeluar:
          context.state = SuratMenu(previous: this, jenis: Jenis.keluar, service: suratList);
          break;
        case Option.logout:
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

    print("┌──────────────────────────┐");
    print("│ Aplikasi Manajemen Surat │");
    print("└──────────────────────────┘");

    printMenu(options, breakPos: Option.suratKeluar.index);

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
