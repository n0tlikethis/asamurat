import 'dart:io';

import 'package:asamurat/cli/menu/disposisi/create.dart';
import 'package:asamurat/cli/menu/disposisi/delete.dart';
import 'package:asamurat/cli/menu/disposisi/read.dart';
import 'package:asamurat/cli/menu/disposisi/update.dart';
import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/surat/list.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

enum Option {
  undefined(null),
  detail('#'),
  next('N'),
  back('B'),
  previous('0');

  const Option(this.input);

  final String? input;
}

late ServiceSuratPersistent suratList;

class DisposisiList extends Menu {
  Option option = Option.undefined;
  Action action;
  late Surat _suratSelect;
  late bool _disposisiFilter, _disposisiExist;

  int _inputPos = 17;
  int _pageNow = 1;

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.next, text: "Next"),
    OptionsMenu(option: Option.detail, text: "Detail"),
    OptionsMenu(option: Option.back, text: "Back"),
    OptionsMenu(option: Option.previous, text: "Kembali"),
  ];

  DisposisiList({required State previous, required this.action, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;

    options[1].text = action.text;

    _disposisiFilter = action != Action.read;
    _disposisiExist = action != Action.create;


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
        default:
          context.state = this;
          break;
      }
    }
  }

  void _handleAction(Cli context) {
    switch (action) {
      case Action.create:
        context.state = DisposisiCreate(previous: this, surat: _suratSelect, service: suratList);
        break;
      case Action.read:
        context.state = DisposisiRead(previous: this, surat: _suratSelect);
        break;
      case Action.update:
        context.state = DisposisiUpdate(previous: this, surat: _suratSelect, service: suratList);
        break;
      case Action.delete:
        context.state = DisposisiDelete(previous: this, surat: _suratSelect, service: suratList);
        break;
      default: break;
    }
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌───────────────${"─" * (action.text.length + 10)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ Surat Masuk > ${capitalize(action.text)} Disposisi │");
    print("└──────────────────────────┘ └───────────────${"─" * (action.text.length + 10)}─┘");

    showData();

    printOptions(options);

    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");
  }

  void showData() {
    // Initialize table
    List<List<String>> tables = [
      ["#", "No. Surat", "Perihal Surat", "Instruksi", "Diteruskan"]
    ];

    // Get page number
    int page = _pageNow == 1 ? 1 : (_pageNow - 1) * 10 + 1;

    // Fetch data by page number
    _getSuratList().forEach((e) => tables.add([
          (page++).toString(),
          trimString(e.nomor, 25),
          trimString(e.perihal, 35),
          trimString(e.disposisi != null ? e.disposisi!.instruksi : "-", 10),
          trimString(e.disposisi != null ? e.disposisi!.diteruskan : "-", 14)
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

  List<Surat> _getSuratList() {
    return (_disposisiFilter
        ? suratList.getPageFilterDisposisi(_pageNow, _disposisiExist)
        : suratList.getPage(_pageNow, Jenis.masuk));
  }

  int _getSuratListMaxPage() {
    return (_disposisiFilter)
        ? suratList.maxPageFilterDisposisi(_disposisiExist)
        : suratList.maxPage(Jenis.masuk);
  }
}
