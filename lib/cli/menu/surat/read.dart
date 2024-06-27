import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/utils/helpers.dart';

class SuratRead extends Menu {
  Jenis jenis;
  late Surat _surat;

  int _maxWidth = 100;

  late int id;

  SuratRead({required State previous, required Surat surat, required this.jenis}) {
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

    print("┌──────────────────────────┐ ┌─${"─" * (jenis.text.length + 15)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} > Detail Surat │");
    print("└──────────────────────────┘ └─${"─" * (jenis.text.length + 15)}─┘");

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
    print("└─────────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(19, 0);
    print("┌───────────────────────┐");
    print("│ [0] Kembali (default) │");
    print("└───────────────────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(23, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() == '0';
  }
}
