import 'dart:convert';
import 'dart:io';

import 'package:asamurat/models/user.dart';
import 'package:asamurat/utils/linked_list.dart';

List<User> jsonToList(String filePath) {
  final jsonString = File(filePath).readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => User.fromJson(json)).toList();
}

LinkedList jsonToLinkedList(String filePath) {
  final jsonString = File(filePath).readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  final linkedList = LinkedList();
  for (var json in jsonList) {
    linkedList.append(User.fromJson(json));
  }
  
  return linkedList;
}

void writeJsonToFile(Map<String, dynamic> jsonData, String filePath) {
  String jsonString = jsonEncode(jsonData);

  File file = File(filePath);
  file.writeAsStringSync(jsonString);
}

void writeListJsonToFile(List<dynamic> jsonData, String filePath) {
  String jsonString = jsonEncode(jsonData);

  File file = File(filePath);
  file.writeAsStringSync(jsonString);
}
