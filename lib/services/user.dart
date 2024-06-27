import 'dart:convert';
import 'dart:io';

import 'package:asamurat/models/user.dart';
import 'package:asamurat/utils/json.dart';
import 'package:asamurat/utils/linked_list.dart';

abstract class InterfaceServiceUser {
  /// Saves info from [user] in a persistent store
  void create({required User user});

  /// Update [user] data from persistent store
  void update({required User user});

  /// Remove [user] info from persistent store
  void delete({required User user});

  /// Get data [user] in a list with pagination
  void getPage(int page);

  /// Get max page from list [user]
  int maxPage();

  /// Get id from last [user]
  int get lastId;
}

class ServiceUserPersistent implements InterfaceServiceUser {
  static LinkedList<User> _user = LinkedList<User>();
  static late String _filePath;

  ServiceUserPersistent();

  factory ServiceUserPersistent.fromJsonList({required String filePath}) {
    final jsonString = File(filePath).readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(jsonString);

    _filePath = filePath;
    for (var json in jsonList) {
      _user.append(User.fromJson(json));
    }

    return ServiceUserPersistent();
  }

  @override
  void create({required User user}) {
    _user.append(user);
    _saveJson();
  }

  @override
  void update({required User user}) {
    for (int i = 0; i < _user.length; i++) {
      if (_user.nodeAt(i)!.value.id == user.id)
        _user.replaceAt(i, user);
    }
    _saveJson();
  }

  @override
  void delete({required User user}) {
    for (int i = 0; i < _user.length; i++) {
      if (_user.nodeAt(i)!.value == user)
        _user.removeAt(i);
    }
    _saveJson();
  }

  @override
  List<User> getPage(int page) {
    List<User> listUser = [];

    int itemsPerPage = 10;
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= _user.length) {
      return [];
    }

    for (int i = 0; i < endIndex; i++) {
      if (_user.nodeAt(i) != null)
        listUser.add(_user.nodeAt(i)!.value);
    }

    return listUser;
  }

  @override
  int maxPage() => _user.length ~/ 10 + 1; // 10 / page

  @override
  int get lastId => _user.tail!.value.id;

  void _saveJson() {
    //writeListJsonToFile(_user.map((u) => u.toJson()).toList(), _filePath);
    writeListJsonToFile(_user.mapToList((user) => user.toJson()), _filePath);
  }
}
