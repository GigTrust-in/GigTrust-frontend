import 'package:flutter/material.dart';
import '../models/role.dart';

class User {
  final String name;
  final String email;
  final Role role;
  final String? avatarUrl;

  User({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  User copyWith({String? name, String? email, Role? role, String? avatarUrl}) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void login(String email, Role role) {
    _user = User(name: email.split('@')[0], email: email, role: role);
    notifyListeners();
  }

  void register(String name, String email, Role role) {
    _user = User(name: name, email: email, role: role);
    notifyListeners();
  }

  void updateAvatar(String? path) {
    if (_user == null) return;
    _user = _user!.copyWith(avatarUrl: path);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
