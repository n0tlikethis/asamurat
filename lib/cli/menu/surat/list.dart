import 'dart:io';

import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/surat/delete.dart';
import 'package:asamurat/cli/menu/surat/read.dart';
import 'package:asamurat/cli/menu/surat/update.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

enum Action {
  create("Tambah"),
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
  previous('0'),
  list('L'),
  sort('D'),
  search('S');

  const Option(this.input);

  final String? input;
}

late ServiceSuratPersistent suratList;

class SuratList extends Menu {
  Option option = Option.undefined;
  Option mode = Option.list;
  Action action;
  Jenis jenis;
  late Surat _suratSelect;

  int _inputPos = 17;
  int _pageNow = 1;
  String _searchKey = "";

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.next, text: "Next"),
    OptionsMenu(option: Option.detail, text: "Detail"),
    OptionsMenu(option: Option.back, text: "Back"),
    OptionsMenu(option: Option.previous, text: "Kembali"),
    OptionsMenu(option: Option.list, text: "Show All"),
  ];

  SuratList({required State previous, required this.action, required this.jenis, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;

    options[1].text = action.text;
    _updateMode();

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
          if (_pageNow < _getSuratListMaxPage()) _pageNow++;
          context.state = this;
          break;
        case Option.back:
          if (_pageNow > 1) _pageNow--;
          context.state = this;
          break;
        case Option.previous:
          context.state = previous!;
          break;
        case Option.list:
        case Option.sort:
        case Option.search:
          _pageNow = 1;
          _updateMode();
          context.state = this;
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
        context.state = SuratRead(previous: this, surat: _suratSelect, jenis: jenis);
        break;
      case Action.update:
        context.state = SuratUpdate(previous: this, surat: _suratSelect, jenis: jenis, service: suratList);
        break;
      case Action.delete:
        context.state = SuratDelete(previous: this, surat: _suratSelect, jenis: jenis, service: suratList);
        break;
      default: break;
    }
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌─${"─" * (jenis.text.length + action.text.length + 9)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} > ${capitalize(action.text)} Surat │");
    print("└──────────────────────────┘ └─${"─" * (jenis.text.length + action.text.length + 9)}─┘");

    showData();

    printOptions(options);

    if (mode == Option.search) {
      print("┌──────────────────────────┐ ┌─────────${"─" * _searchKey.length}─┐");
      print("│ Pilih opsi:              │ │ Search: $_searchKey │");
      print("└──────────────────────────┘ └─────────${"─" * _searchKey.length}─┘");
    } else {
      print("┌──────────────────────────┐");
      print("│ Pilih opsi:              │");
      print("└──────────────────────────┘");
    }
  }

  void showData() {
    // Initialize table
    List<List<String>> tables = [
      ["#", "No. Surat", "Perihal Surat", "Asal Surat", "Tanggal Surat"]
    ];

    // Get page number
    int page = _pageNow == 1 ? 1 : (_pageNow - 1) * 10 + 1;

    // Fetch data by page number
    _getSuratList().forEach((e) => tables.add([
          (page++).toString(),
          trimString(e.nomor, 25),
          trimString(e.perihal, 35),
          trimString(e.pengirim, 20),
          e.tanggal
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
      _suratSelect = _getSuratList()[userI - 1];

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

  void _handleSearch() {
    setCursor(_inputPos - 1, 0);
    print("┌──────────────────────────┐");
    print("│ Nomor:                   │");
    print("└──────────────────────────┘");

    setCursor(_inputPos, 10);
    String? searchKey = stdin.readLineSync();

    if (searchKey == null || searchKey.isEmpty) {
      setCursor(_inputPos - 1, 0);
      print(colorizeText("┌──────────────────────────┐", TextColor.red));
      print(colorizeText("│ Tidak boleh kosong!      │", TextColor.red));
      print(colorizeText("└──────────────────────────┘", TextColor.red));
      sleep(const Duration(seconds: 1));
      return _handleSearch();
    }

    _searchKey = searchKey;
  }

  void _updateMode() {
    mode = option;
    options.removeLast();

    switch (mode) {
      case Option.search:
        _handleSearch();
        continue sortCase;
      sortCase:
      case Option.sort:
        options.removeLast();
        options.add(OptionsMenu(option: Option.list, text: "Show All"));
        break;
      default:
        options.add(OptionsMenu(option: Option.sort, text: "Sort by Tanggal"));
        options.add(OptionsMenu(option: Option.search, text: "Search by Nomor Surat"));
        break;
    }
  }

  List<Surat> _getSuratList() {
    switch (mode) {
      case Option.sort:
        return suratList.getPageSortDate(_pageNow, jenis).reversed.toList();
      case Option.search:
        return suratList.getPageSearchNomor(_pageNow, jenis, _searchKey);
      default:
        return suratList.getPage(_pageNow, jenis);
    }
  }

  int _getSuratListMaxPage() {
    switch (mode) {
      case Option.search:
        return suratList.maxPageSearchNomor(jenis, _searchKey);
      default:
        return suratList.maxPage(jenis);
    }
  }
}
