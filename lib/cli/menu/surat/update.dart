import 'dart:io';

import 'package:asamurat/cli/state.dart';
import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/services/surat.dart';
import 'package:asamurat/utils/helpers.dart';

String emptyWarning = "Data harus diisi! ";
String invalidFormatWarning = "Input salah! ";

late ServiceSuratPersistent suratList;

class SuratUpdate extends Menu {
  Jenis jenis;
  late Surat _surat;

  int _maxWidth = 100;
  int _inputPos = 17;

  late String nomor;
  late String klasifikasi;
  late String pengirim;
  late String perihal;
  late String? keterangan;
  late String tanggal;

  SuratUpdate({required State previous, required Surat surat, required this.jenis, required ServiceSuratPersistent service}) {
    super.previous = previous;
    suratList = service;
    _surat = surat;
    isReady = true;
  }

  @override
  void handler({required Cli context}) {
    showMenu();

    nomor = _askNomor();
    klasifikasi = _askKlasifikasi();
    pengirim = _askPengirim();
    perihal = _askPerihal();
    keterangan = _askKeterangan();
    tanggal = _askTanggal();

    if (_askConfirmation()) {
      try {
        updateSurat();
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

    print("┌──────────────────────────┐ ┌─${"─" * (jenis.text.length + 13)}─┐");
    print("│ Aplikasi Manajemen Surat │ │ ${jenis.text} > Edit Surat │");
    print("└──────────────────────────┘ └─${"─" * (jenis.text.length + 13)}─┘");

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
    print("┌───────────────────┬──────────────────────┬───────────┐");
    print("│ Simpan perubahan? │ [Y] Simpan (default) │ [N] Batal │");
    print("└───────────────────┴──────────────────────┴───────────┘");
    print("┌──────────────────────────┐");
    print("│ Pilih opsi:              │");
    print("└──────────────────────────┘");

    setCursor(23, 15);
    String? readConfirmation = stdin.readLineSync();

    return readConfirmation == null || readConfirmation.toLowerCase() != 'n';
  }

  void updateSurat() {
    Surat surat = Surat(
        id: _surat.id,
        nomor: nomor,
        jenis: jenis,
        klasifikasi: klasifikasi,
        pengirim: pengirim,
        perihal: perihal,
        keterangan: keterangan,
        disposisi: _surat.disposisi,
        tanggal: tanggal);
    suratList.update(surat: surat);
  }

  String _askNomor() {
    int inPos = 7;
    setCursor(inPos, _inputPos);
    String? readNomor = stdin.readLineSync();

    if (readNomor == null || readNomor.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.nomor);
      return _surat.nomor;
    }

    return readNomor;
  }

  String _askKlasifikasi() {
    int inPos = 9;
    setCursor(inPos, _inputPos);
    String? readKlasifikasi = stdin.readLineSync();

    if (readKlasifikasi == null || readKlasifikasi.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.klasifikasi);
      return _surat.klasifikasi;
    }

    return readKlasifikasi;
  }

  String _askPengirim() {
    int inPos = 11;
    setCursor(inPos, _inputPos);
    String? readPengirim = stdin.readLineSync();

    if (readPengirim == null || readPengirim.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.pengirim);
      return _surat.pengirim;
    }

    return readPengirim;
  }

  String _askPerihal() {
    int inPos = 13;
    setCursor(inPos, _inputPos);
    String? readPerihal = stdin.readLineSync();

    if (readPerihal == null || readPerihal.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.perihal);
      return _surat.perihal;
    }

    return readPerihal;
  }

  String? _askKeterangan() {
    int inPos = 15;
    setCursor(inPos, _inputPos);
    String? readKeterangan = stdin.readLineSync();

    if (readKeterangan == null || readKeterangan.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.keterangan ?? "-");
      return _surat.keterangan;
    }

    return readKeterangan;
  }

  String _askTanggal() {
    int inPos = 17;
    setCursor(inPos, _inputPos);
    String? readTanggal = stdin.readLineSync();

    if (readTanggal == null || readTanggal.isEmpty) {
      setCursor(inPos, _inputPos);
      print(_surat.tanggal);
      return _surat.tanggal;
    }

    if (_checkInputDate(readTanggal, inPos)) return _askTanggal();

    return readTanggal;
  }

  bool _checkInputDate(String? input, int pos) {
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
