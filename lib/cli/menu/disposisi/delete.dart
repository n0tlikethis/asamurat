import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

late ServiceSuratPersistent suratList;

class DisposisiDelete extends Menu {
  late Surat _surat;

  int _maxWidth = 100;

  late int id;

  DisposisiDelete({required State previous, required Surat surat, required ServiceSuratPersistent service}) {
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
        deleteDisposisi();
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

    print("┌──────────────────────────┐ ┌───────────────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ Surat Masuk > Hapus Disposisi │");
    print("└──────────────────────────┘ └───────────────────────────────┘");

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
    print("│ ${"Disposisi".padLeft(_maxWidth + 14)} │");
    print("├─────────────┬─${"─" * _maxWidth}─┤");
    print("│ Instruksi   │ ${_surat.disposisi!.instruksi.padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Diteruskan  │ ${_surat.disposisi!.diteruskan.padRight(_maxWidth)} │");
    print("└─────────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(25, 0);
    print("┌──────────────┬─────────────────────┬───────────┐");
    print("│ Hapus surat? │ [Y] Hapus (default) │ [N] Batal │");
    print("└──────────────┴─────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(29, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void deleteDisposisi() {
    Surat suratMasuk = Surat(
        id: _surat.id,
        nomor: _surat.nomor,
        jenis: _surat.jenis,
        klasifikasi: _surat.klasifikasi,
        pengirim: _surat.pengirim,
        perihal: _surat.perihal,
        keterangan: _surat.keterangan,
        disposisi: null,
        tanggal: _surat.tanggal);
    suratList.update(surat: suratMasuk);
  }
}
