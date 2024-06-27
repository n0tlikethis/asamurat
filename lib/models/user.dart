import 'package:asamurat/models/enums.dart';
import 'package:asamurat/utils/helpers.dart';

class User {
  late int id;
  late String nama;
  late String username;
  late String password;
  late Role role;

  User(
      {required this.id,
      required this.nama,
      required this.username,
      required this.password,
      required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        nama: json['nama'],
        username: json['username'],
        password: rot13(json['password']),
        role: Role.values[json['role']]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['nama'] = nama;
    data['username'] = username;
    data['password'] = rot13(password);
    data['role'] = role.index;

    return data;
  }
}
