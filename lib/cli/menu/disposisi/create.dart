import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

const int maxRetries = 3;
String emptyWarning = "Data harus diisi! ";
String invalidFormatWarning = "Input salah! ";

late ServiceSuratPersistent suratList;

class DisposisiCreate extends Menu {
  late Surat _surat;

  int _errorCount = 0;
  int _maxWidth = 100;
  int _inputPos = 17;

  late Disposisi? disposisi;
  late String instruksi;
  late String diteruskan;

  DisposisiCreate({required State previous, required Surat surat, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;
    _surat = surat;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();
    instruksi = _checkRetries(_askInstruksi(), _askInstruksi);

    if (instruksi.isNotEmpty) {
      diteruskan = _askDiteruskan();

      disposisi = Disposisi(instruksi: instruksi, diteruskan: diteruskan);

      if (_askConfirmation()) {
        try {
          saveDisposisi();
          print("success");
        } catch (e) {
          print("failed");
        }
      }
    }

    context.state = previous!;
  }

  @override
  void showMenu() {
    clear();

    print("┌──────────────────────────┐ ┌────────────────────────────────┐");
    print("│ Aplikasi Manajemen Surat │ │ Surat Masuk > Tambah Disposisi │");
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
    print("│ Instruksi   │ ${" ".padRight(_maxWidth)} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Diteruskan  │ ${" ".padRight(_maxWidth)} │");
    print("└─────────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(25, 0);
    print("┌───────────────────┬──────────────────────┬───────────┐");
    print("│ Simpan disposisi? │ [Y] Simpan (default) │ [N] Batal │");
    print("└───────────────────┴──────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(29, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void saveDisposisi() {
    Surat surat = Surat(
        id: _surat.id,
        nomor: _surat.nomor,
        jenis: _surat.jenis,
        klasifikasi: _surat.klasifikasi,
        pengirim: _surat.pengirim,
        perihal: _surat.perihal,
        keterangan: _surat.keterangan,
        disposisi: disposisi,
        tanggal: _surat.tanggal);
    suratList.update(surat: surat);
  }

  String _askInstruksi() {
    int inPos = 21;
    setCursor(inPos, _inputPos);
    String? readInstruksi = stdin.readLineSync();

    if (_checkInputNull(readInstruksi, inPos)) null;

    return readInstruksi!;
  }

  String _askDiteruskan() {
    int inPos = 23;
    setCursor(inPos, _inputPos);
    String? readDiteruskan = stdin.readLineSync();

    if (_checkInputNull(readDiteruskan, inPos)) return _askDiteruskan();

    return readDiteruskan!;
  }

  String _checkRetries(String result, Function cb) {
    if (result.isEmpty) {
      if (_errorCount < maxRetries - 1) {
        _errorCount++;
        return _checkRetries(cb(), cb);
      }

      return "";
    }

    return result;
  }

  bool _checkInputNull(String? input, int pos) {
    if (input == null || input.isEmpty) {
      setCursor(pos, _inputPos);
      stdout.write(colorizeText(emptyWarning, TextColor.red));
      sleep(const Duration(seconds: 1));

      setCursor(pos, _inputPos);
      stdout.write(" " * emptyWarning.length);

      return true;
    } else {
      return false;
    }
  }
}
