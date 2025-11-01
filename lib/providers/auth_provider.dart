import 'package:flutter/material.dart';
import '../models/role.dart';

class User {
  final String name;
  final String email;
  final Role role;
  final String? avatarUrl;
  final String gender;
  final String skills;
  final String? password;

  User({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.gender = 'Other',
    this.skills = '',
    this.password,
  });

  User copyWith({
    String? name,
    String? email,
    Role? role,
    String? avatarUrl,
    String? gender,
    String? skills,
    String? password,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      skills: skills ?? this.skills,
      password: password ?? this.password,
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

  void updateProfile({
    String? name,
    String? gender,
    String? skills,
    String? newPassword,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      gender: gender,
      skills: skills,
      password: newPassword ?? _user!.password,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}