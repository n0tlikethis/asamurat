import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

const int maxRetries = 3;
String emptyWarning = "Data harus diisi! ";
String invalidFormatWarning = "Input salah! ";

late ServiceSuratPersistent suratList;

class SuratCreate extends Menu {
  Jenis jenis;

  int _errorCount = 0;
  int _maxWidth = 100;
  int _inputPos = 17;

  late int id;
  late String nomor;
  late String klasifikasi;
  late String pengirim;
  late String perihal;
  late String? keterangan;
  late String tanggal;

  SuratCreate({required State previous, required this.jenis, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;
    isReady = true;

    id = suratList.lastId + 1;
  }

  @override
  void handler({required Cli context}) {
    showMenu();
    nomor = _checkRetries(_askNomor(), _askNomor);

    if (nomor.isNotEmpty) {
      klasifikasi = _askKlasifikasi();
      pengirim = _askPengirim();
      perihal = _askPerihal();
      keterangan = _askKeterangan();
      tanggal = _askTanggal();

      if (_askConfirmation()) {
        try {
          saveSurat();
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

    print("┌──────────────────────────┐ ┌─${"─" * (jenis.text.length + 15)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} > Tambah Surat │");
    print("└──────────────────────────┘ └─${"─" * (jenis.text.length + 15)}─┘");

    showDetails();
  }

  void showDetails() {
    print("┌───────────────${"─" * _maxWidth}─┐");
    print("│ ${"Detail Surat".padRight(_maxWidth + 14)} │");
    print("├─────────────┬─${"─" * _maxWidth}─┤");
    print("│ Nomor Surat │ ${" " * _maxWidth} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Klarifikasi │ ${" " * _maxWidth} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Pengirim    │ ${" " * _maxWidth} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Perihal     │ ${" " * _maxWidth} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Keterangan  │ ${" " * _maxWidth} │");
    print("├─────────────┼─${"─" * _maxWidth}─┤");
    print("│ Tanggal     │ ${" " * (_maxWidth - 23)} [ Format: DD-MM-YYYY ] │");
    print("└─────────────┴─${"─" * _maxWidth}─┘");
  }

  bool _askConfirmation() {
    setCursor(19, 0);
    print("┌───────────────┬──────────────────────┬───────────┐");
    print("│ Simpan surat? │ [Y] Simpan (default) │ [N] Batal │");
    print("└───────────────┴──────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(23, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void saveSurat() {
    Surat surat = Surat(
        id: id,
        nomor: nomor,
        jenis: jenis,
        klasifikasi: klasifikasi,
        pengirim: pengirim,
        perihal: perihal,
        keterangan: keterangan,
        disposisi: null,
        tanggal: tanggal);
    suratList.create(surat: surat);
  }

  String _askNomor() {
    int inPos = 7;
    setCursor(inPos, _inputPos);
    String? readNomor = stdin.readLineSync();

    if (_checkInputNull(readNomor, inPos)) null;

    return readNomor!;
  }

  String _askKlasifikasi() {
    int inPos = 9;
    setCursor(inPos, _inputPos);
    String? readKlasifikasi = stdin.readLineSync();

    if (_checkInputNull(readKlasifikasi, inPos)) return _askKlasifikasi();

    return readKlasifikasi!;
  }

  String _askPengirim() {
    int inPos = 11;
    setCursor(inPos, _inputPos);
    String? readPengirim = stdin.readLineSync();

    if (_checkInputNull(readPengirim, inPos)) return _askPengirim();

    return readPengirim!;
  }

  String _askPerihal() {
    int inPos = 13;
    setCursor(inPos, _inputPos);
    String? readPerihal = stdin.readLineSync();

    if (_checkInputNull(readPerihal, inPos)) return _askPerihal();

    return readPerihal!;
  }

  String? _askKeterangan() {
    int inPos = 15;
    setCursor(inPos, _inputPos);
    String? readKeterangan = stdin.readLineSync();

    if (readKeterangan == null || readKeterangan.isEmpty) readKeterangan = null;

    return readKeterangan;
  }

  String _askTanggal() {
    int inPos = 17;
    setCursor(inPos, _inputPos);
    String? readTanggal = stdin.readLineSync();

    if (_checkInputDate(readTanggal, inPos)) return _askTanggal();

    return readTanggal!;
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

  bool _checkInputDate(String? input, int pos) {
    if (_checkInputNull(input, pos)) return true;

    RegExp regex =
        RegExp(r'^(0[1-9]|[1-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-\d{4}$');

    if (!regex.hasMatch(input!)) {
      setCursor(pos, _inputPos);
      stdout.write(colorizeText(invalidFormatWarning, TextColor.red));
      sleep(const Duration(seconds: 1));

      setCursor(pos, _inputPos);
      stdout.write(" " * invalidFormatWarning.length);

      return true;
    } else {
      return false;
    }
  }
}
