import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/utils/helpers.dart';

class DisposisiRead extends Menu {
  late Surat _surat;

  int _maxWidth = 100;

  late int id;

  DisposisiRead({required State previous, required Surat surat}) {
    super.previous = previous;
    _surat = surat;
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

    print("┌──────────────────────────┐ ┌────────────────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ Surat Masuk > Detail Disposisi │");
    print("└──────────────────────────┘ └────────────────────────────────┘");

    showDetails();
  }

  void showDetails() {
    print("┌───────────────${"─" * _maxWidth}─┐");
    print("│ ${"Detail Surat".padRight(_maxWidth + 14)} │");
    print("├─────────────┬─${"─" * _maxWidth}─┤");
    print("│ Nomor Surat │ ${_surat.nomor.padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Klarifikasi │ ${_surat.klasifikasi.padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Pengirim    │ ${_surat.pengirim.padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Perihal     │ ${_surat.perihal.padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Keterangan  │ ${(_surat.keterangan ?? "-").padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Tanggal     │ ${_surat.tanggal.padRight(_maxWidth)} │");
    print("├─────────────┴─${"─" * _maxWidth}─┤");
    print("│ ${"Disposisi".padRight(_maxWidth + 14)} │");
    print("├─────────────┬─${"─" * _maxWidth}─┤");
    if (_surat.disposisi != null) {
      print("│ Instruksi   │ ${_surat.disposisi!.instruksi.padRight(_maxWidth)} │");
      print("├─────────────┼─${"─" * _maxWidth}─┤");
      print("│ Diteruskan  │ ${_surat.disposisi!.diteruskan.padRight(_maxWidth)} │");
    } else {
      print("│ Instruksi   │ ${"-".padRight(_maxWidth)} │");
      print("├─────────────┼─${"─" * _maxWidth}─┤");
      print("│ Diteruskan  │ ${"-".padRight(_maxWidth)} │");
    }
    print("└─────────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(25, 0);
    print("┌───────────────────────┐");
    print("│ [0] Kembali (default) │");
    print("└───────────────────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(29, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() == '0';
  }
}
