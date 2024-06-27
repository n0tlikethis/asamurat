import 'dart:io';

import 'package:asamurat/cli/menu/disposisi/list.dart';
import 'package:asamurat/cli/menu/options.dart';
import 'package:asamurat/cli/menu/surat/create.dart';
import 'package:asamurat/cli/menu/surat/list.dart';
import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/services/auth.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

enum Option { undefined, read, create, update, delete, back }
enum DispositionOption { read, create, update, delete }

late ServiceSuratPersistent suratList;

class SuratMenu extends Menu {
  dynamic option = Option.undefined;
  Jenis jenis;

  int _inputPos = 15;
  dynamic _breakPos = Option.delete.index;

  List<OptionsMenu> options = [
    OptionsMenu(option: Option.read, text: "Daftar Surat"),
    OptionsMenu(option: Option.create, text: "Tambah Surat"),
    OptionsMenu(option: Option.update, text: "Edit Surat"),
    OptionsMenu(option: Option.delete, text: "Hapus Surat"),
    OptionsMenu(option: Option.back, text: "Kembali"),
  ];

  void _checkUserRole() {
    if (AuthService.loggedUser.role != Role.officer && jenis == Jenis.masuk) {
      _inputPos = 20;
      _breakPos = [Option.delete.index, DispositionOption.delete.index];
      options.insertAll(Option.delete.index, [
        OptionsMenu(option: DispositionOption.read, text: "Daftar Disposisi"),
        OptionsMenu(option: DispositionOption.create, text: "Tambah Disposisi"),
        OptionsMenu(option: DispositionOption.update, text: "Edit Disposisi"),
        OptionsMenu(option: DispositionOption.delete, text: "Hapus Disposisi"),
      ]);
    }
  }

  SuratMenu({required State previous, required this.jenis, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;
    _checkUserRole();
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    if (!_handleOption()) {
      clear();
      exit(-1);
    } else {
      switch (option) {
        // Surat
        case Option.create:
          context.state = SuratCreate(previous: this, jenis: jenis, service: suratList);
          break;
        case Option.read:
          context.state = SuratList(previous: this, action: Action.read, jenis: jenis, service: suratList);
          break;
        case Option.update:
          context.state = SuratList(previous: this, action: Action.update, jenis: jenis, service: suratList);
          break;
        case Option.delete:
          context.state = SuratList(previous: this, action: Action.delete, jenis: jenis, service: suratList);
          break;
        // Disposisi
        case DispositionOption.create:
          context.state = DisposisiList(previous: this, action: Action.create, service: suratList);
          break;
        case DispositionOption.read:
          context.state = DisposisiList(previous: this, action: Action.read, service: suratList);
          break;
        case DispositionOption.update:
          context.state = DisposisiList(previous: this, action: Action.update, service: suratList);
          break;
        case DispositionOption.delete:
          context.state = DisposisiList(previous: this, action: Action.delete, service: suratList);
          break;
        // Back
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

    print("┌──────────────────────────┐ ┌─${"─" * jenis.text.length}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} │");
    print("└──────────────────────────┘ └─${"─" * jenis.text.length}─┘");

    printMenu(options, breakPos: _breakPos);

    print("┌──────────────────────────┐");
    print("│ Pilih menu:              │");
    print("└──────────────────────────┘");
  }

  // Gets [option] as Option type
  dynamic _getCastOption(int option) {
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
