import 'dart:io';

import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/user/delete.dart';
import 'package:asamurat/cli/menu/user/read.dart';
import 'package:asamurat/cli/menu/user/update.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/user.dart';
import 'package:asamurat/services/user.dart';
import 'package:asamurat/utils/helpers.dart';

enum Action {
  read("Detail"),
  update("Edit"),
  delete("Hapus");

  const Action(this.text);

  final String text;
}

enum Option {
  undefined(null),
  detail('#'),
  next('N'),
  back('B'),
  previous('0');

  const Option(this.input);

  final String? input;
}

late ServiceUserPersistent userList;

class UserList extends Menu {
  Option option = Option.undefined;
  Action action;
  late User _userSelect;

  int _inputPos = 17;
  int _pageNow = 1;

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.next, text: "Next"),
    OptionsMenu(option: Option.detail, text: "Detail"),
    OptionsMenu(option: Option.back, text: "Back"),
    OptionsMenu(option: Option.previous, text: "Kembali"),
  ];

  UserList({required State previous, required this.action, required ServiceUserPersistent service}) {
    super.previous = previous;
    userList = service;

    options[1].text = action.text;

    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    //showMenu();

    if (!_handleOption()) {
      clear();
      exit(-1);
    } else {
      switch (option) {
        case Option.detail:
          _handleAction(context);
          break;
        case Option.next:
          if (_pageNow < userList.maxPage()) _pageNow++;
          context.state = this;
          break;
        case Option.back:
          if (_pageNow > 1) _pageNow--;
          context.state = this;
          break;
        case Option.previous:
          context.state = previous!;
          break;
        default:
          context.state = this;
          break;
      }
    }
  }

  void _handleAction(Cli context) {
    switch (action) {
      case Action.read:
        context.state = UserRead(previous: this, user: _userSelect);
        break;
      case Action.update:
        context.state =
            UserUpdate(previous: this, user: _userSelect, service: userList);
        break;
      case Action.delete:
        context.state =
            UserDelete(previous: this, user: _userSelect, service: userList);
        break;
    }
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ User > Daftar User │");
    print("└──────────────────────────┘ └────────────────────┘");

    showData();

    printOptions(options);

    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");
  }

  void showData() {
    // Initialize table
    List<List<String>> tables = [
      ["#", "Username", "Password", "Role"]
    ];

    // Get page number
    int page = _pageNow == 1 ? 1 : (_pageNow - 1) * 10 + 1;

    // Fetch data by page number
    userList.getPage(_pageNow).forEach((e) => tables.add([
          (page++).toString(),
          trimString(e.username, 12),
          maskString(trimString(e.password, 8), '*'),
          e.role.name
        ]));

    // Calculate cursor position
    int tableSize = tables.length;
    _inputPos = 9 + (tableSize * 2);

    // Print table
    printTable(tables);
  }

  // Gets [option] as Option type
  Option _getCastOption(String? option, List listChars) {
    try {
      if (option == null) throw "invalid";

      // Check if input is char
      if (listChars.isNotEmpty && listChars.contains(option)) {
        for (var menu in options) {
          if (menu.option.input?.toLowerCase() == option) return menu.option;
        }
      }

      // Check if input is number
      int userI = int.parse(option);
      if (userI == 0) return options[3].option;

      // Fetch data based on page position
      userI = userI <= 10 ? userI : userI - ((_pageNow - 1) * 10);

      // Get selected user data (used for read, update, delete)
      _userSelect = userList.getPage(_pageNow)[userI - 1];

      return options[1].option;
    } catch (err) {
      return Option.undefined;
    }
  }

  ///// Returns true if the user selected a correct answer and handles wrong options
  bool _handleOption() {
    // Print menu everytime _handleOption() called
    showMenu();

    // Set cursor position to input pos
    setCursor(_inputPos, 15);

    // List all of allowed char input
    List<String?> chars = [];
    chars.addAll(options.expand((opt) => [opt.option.input?.toLowerCase()]));

    // Initialize min and max page
    int min = _pageNow == 1 ? 1 : (_pageNow - 1) * 10 + 1;
    int max = _pageNow == 1 ? 10 : _pageNow * 10;

    // Get option by user input
    option = _getCastOption(
        checkOptionWithChar(
            option: stdin.readLineSync(), min: min, max: max, listChars: chars),
        chars);

    // False input
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
