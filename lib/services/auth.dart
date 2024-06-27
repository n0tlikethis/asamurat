import 'package:asamurat/models/user.dart';

class AuthService {
  static late List<User> _users;
  static late User _session;

  AuthService._();

  static final AuthService _instance = AuthService._();

  factory AuthService(List<User> data) {
    _users = data;
    return _instance;
  }

  User login({required String username, required String password}) {
    final user = _users.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse: () => throw "User tidak ditemukan!");
    return _session = user;
  }

  static User get loggedUser => _session;
}
