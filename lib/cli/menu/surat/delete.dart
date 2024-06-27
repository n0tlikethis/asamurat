import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

late ServiceSuratPersistent suratList;

class SuratDelete extends Menu {
  Jenis jenis;
  late Surat _surat;

  int _maxWidth = 100;

  late int id;

  SuratDelete({required State previous, required Surat surat, required this.jenis, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;
    _surat = surat;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();

    if (_askConfirmation()) {
      try {
        deleteSurat();
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

    print("┌──────────────────────────┐ ┌─${"─" * (jenis.text.length + 14)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} > Hapus Surat │");
    print("└──────────────────────────┘ └─${"─" * (jenis.text.length + 14)}─┘");

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
    print("┌──────────────┬─────────────────────┬───────────┐");
    print("│ Hapus surat? │ [Y] Hapus (default) │ [N] Batal │");
    print("└──────────────┴─────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(23, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void deleteSurat() {
    suratList.delete(surat: _surat);
  }
}
