import 'package:asamurat/utils/helpers.dart' as helpers;

enum Role { admin, headmaster, officer }

enum Jenis {
  masuk,
  keluar;

  String get text => "Surat ${helpers.capitalize(name)}";

  @override
  String toString() => text;
}

enum Klasifikasi {
  dinas,
  keputusan,
  tugas,
  kunjungan,
  dispensasi,
  undangan,
  keterangan;

  @override
  String toString() => "Surat ${helpers.capitalize(name)}";
}
