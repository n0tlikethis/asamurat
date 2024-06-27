import 'package:asamurat/models/enums.dart';

class Surat {
  late int id;
  late String nomor;
  late Jenis jenis;
  late String klasifikasi;
  late String pengirim;
  late String perihal;
  late String? keterangan;
  late String tanggal;
  late Disposisi? disposisi;

  Surat(
      {required this.id,
      required this.nomor,
      required this.jenis,
      required this.klasifikasi,
      required this.perihal,
      required this.pengirim,
      required this.keterangan,
      required this.tanggal,
      required this.disposisi});

  factory Surat.fromJson(Map<String, dynamic> json) {
    return Surat(
        id: json['id'],
        nomor: json['nomor'],
        jenis: Jenis.values[json['jenis']],
        klasifikasi: json['klasifikasi'],
        pengirim: json['pengirim'],
        perihal: json['perihal'],
        keterangan: json['keterangan'],
        tanggal: json['tanggal'],
        disposisi: json['disposisi'] != null
            ? Disposisi.fromJson(json['disposisi'])
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['nomor'] = nomor;
    data['jenis'] = jenis.index;
    data['klasifikasi'] = klasifikasi;
    data['pengirim'] = pengirim;
    data['perihal'] = perihal;
    data['keterangan'] = keterangan;
    data['tanggal'] = tanggal;
    data['disposisi'] = disposisi;

    return data;
  }
}

class Disposisi {
  late String instruksi;
  late String diteruskan;

  Disposisi({required this.instruksi, required this.diteruskan});

  factory Disposisi.fromJson(Map<String, dynamic> json) {
    return Disposisi(
        instruksi: json['instruksi'], diteruskan: json['diteruskan']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['instruksi'] = instruksi;
    data['diteruskan'] = diteruskan;

    return data;
  }
}
