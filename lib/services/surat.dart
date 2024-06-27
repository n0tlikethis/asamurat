import 'dart:convert';
import 'dart:io';

import 'package:asamurat/models/enums.dart';
import 'package:asamurat/models/surat.dart';
import 'package:asamurat/utils/json.dart';
import 'package:asamurat/utils/linked_list.dart';
import 'package:asamurat/utils/search.dart';
import 'package:asamurat/utils/sort.dart';

abstract class InterfaceServiceSurat {
  /// Saves info from [surat] in a persistent store
  void create({required Surat surat});

  /// Update [surat] data from persistent store
  void update({required Surat surat});

  /// Remove [surat] info from persistent store
  void delete({required Surat surat});

  /// Get data [surat] by type in a list with pagination
  void getPage(int page, Jenis jenis);

  /// Get data [surat] by type sorted by date in a list with pagination
  void getPageSortDate(int page, Jenis jenis);

  /// Get data [surat] by type search by nomor in a list with pagination
  void getPageSearchNomor(int page, Jenis jenis, String nomor);

  /// Get data [surat] by disposition in a list with pagination
  void getPageFilterDisposisi(int page, bool exist);

  /// Get max page from list [surat] by type
  int maxPage(Jenis jenis);

  /// Get max page from list [surat] by type search by nomor
  int maxPageSearchNomor(Jenis jenis, String nomor);

  /// Get max page from list [surat] by disposition
  int maxPageFilterDisposisi(bool exist);

  /// Get id from last [surat]
  int get lastId;
}

class ServiceSuratPersistent implements InterfaceServiceSurat {
  static LinkedList<Surat> _surat = LinkedList<Surat>();
  static late String _filePath;

  ServiceSuratPersistent();

  factory ServiceSuratPersistent.fromJsonList({required String filePath}) {
    final jsonString = File(filePath).readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(jsonString);

    _filePath = filePath;
    for (var json in jsonList) {
      _surat.append(Surat.fromJson(json));
    }

    return ServiceSuratPersistent();
  }

  @override
  void create({required Surat surat}) {
    _surat.append(surat);
    _saveJson();
  }

  @override
  void update({required Surat surat}) {
    for (int i = 0; i < _surat.length; i++) {
      if (_surat.nodeAt(i)!.value.id == surat.id)
        _surat.replaceAt(i, surat);
    }
    _saveJson();
  }

  @override
  void delete({required Surat surat}) {
    for (int i = 0; i < _surat.length; i++) {
      if (_surat.nodeAt(i)!.value == surat)
        _surat.removeAt(i);
    }
    _saveJson();
  }

  @override
  List<Surat> getPage(int page, Jenis jenis) {
    List<Surat> listSurat = _suratByType(jenis);

    int itemsPerPage = 10;
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= listSurat.length) {
      return [];
    }

    return listSurat.sublist(startIndex, endIndex.clamp(0, listSurat.length));
  }

  @override
  List<Surat> getPageSortDate(int page, Jenis jenis) {
    List<Surat> listSurat = _suratByType(jenis);
    mergeSort(listSurat);

    int itemsPerPage = 10;
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= listSurat.length) {
      return [];
    }

    return listSurat.sublist(startIndex, endIndex.clamp(0, listSurat.length));
  }

  @override
  List<Surat> getPageSearchNomor(int page, Jenis jenis, String nomor) {
    List<Surat> listSurat = _suratByType(jenis);
    List<Surat> listResult = linearSearch(listSurat, nomor);

    int itemsPerPage = 10;
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= listResult.length) {
      return [];
    }

    return listResult.sublist(startIndex, endIndex.clamp(0, listResult.length));
  }

  @override
  List<Surat> getPageFilterDisposisi(int page, bool exist) {
    List<Surat> listSurat = _suratByType(Jenis.masuk)
        .where((s) => (s.disposisi != null) == exist)
        .toList();

    int itemsPerPage = 10;
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= listSurat.length) {
      return [];
    }

    return listSurat.sublist(startIndex, endIndex.clamp(0, listSurat.length));
  }

  @override
  int maxPage(Jenis jenis) {
    List<Surat> listSurat = _suratByType(jenis);
    return listSurat.length ~/ 10 + 1; // 10 / page
  }

  @override
  int maxPageSearchNomor(Jenis jenis, String nomor) {
    List<Surat> listSurat = _suratByType(jenis)
        .where((s) => s.nomor.contains(nomor))
        .toList();
    return listSurat.length ~/ 10 + 1; // 10 / page
  }

  @override
  int maxPageFilterDisposisi(bool exist) {
    List<Surat> listSurat = _suratByType(Jenis.masuk)
        .where((s) => (s.disposisi != null) == exist)
        .toList();
    return listSurat.length ~/ 10 + 1; // 10 / page
  }

  @override
  int get lastId => _surat.tail!.value.id;

  List<Surat> _suratByType(Jenis jenis) =>
      _surat.whereToList((s) => s.jenis == jenis);

  //List<Surat> _suratByDisposisi(bool exist) =>
  //    _surat.where((s) => (s.disposisi != null) == exist).toList();

  void _saveJson() {
    //writeListJsonToFile(_surat.map((s) => s.toJson()).toList(), _filePath);
    writeListJsonToFile(_surat.mapToList((s) => s.toJson()), _filePath);
  }
}
