import 'package:asamurat/models/surat.dart';

// Used for searching [surat] by nomor surat
List<Surat> linearSearch(List<Surat> suratList, String nomor) {
  List<Surat> results = [];

  for (Surat surat in suratList) {
    if (surat.nomor.toLowerCase().contains(nomor.toLowerCase()))
      results.add(surat);
  }

  return results;
}
