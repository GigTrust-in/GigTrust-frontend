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
  final double ratingSum;
  final int ratingCount;

  User({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.gender = 'Other',
    this.skills = '',
    this.password,
    this.ratingSum = 0.0,
    this.ratingCount = 0,
  });

  User copyWith({
    String? name,
    String? email,
    Role? role,
    String? avatarUrl,
    String? gender,
    String? skills,
    String? password,
    double? ratingSum,
    int? ratingCount,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      skills: skills ?? this.skills,
      password: password ?? this.password,
      ratingSum: ratingSum ?? this.ratingSum,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  final Map<String, User> _users = {};

  User? get user => _user;

  /// Attempts to log in. Returns true if credentials match a registered user.
  bool login(String email, String password, Role role) {
    final existing = _users[email];
    if (existing != null && existing.password == password && existing.role == role) {
      _user = existing;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Register a new user and set as current user. Overwrites any existing user with same email.
  void register(String name, String email, Role role, String password) {
    final newUser = User(name: name, email: email, role: role, password: password);
    _users[email] = newUser;
    _user = newUser;
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

  /// Returns a list of users filtered by role.
  List<User> getUsersByRole(Role role) {
    return _users.values.where((u) => u.role == role).toList();
  }

  /// Adds a rating to a user identified by name (in-memory). Updates rating sum and count.
  void addRatingToUserByName(String name, double rating) {
    final entry = _users.entries.firstWhere(
      (e) => e.value.name == name,
      orElse: () => MapEntry('', User(name: '', email: '', role: Role.client)),
    );
    if (entry.key == '') return;
    final u = entry.value;
    final newSum = u.ratingSum + rating;
    final newCount = u.ratingCount + 1;
    final updated = u.copyWith(ratingSum: newSum, ratingCount: newCount);
    _users[entry.key] = updated;
    // If currently signed-in user matches, update _user reference
    if (_user != null && _user!.email == entry.key) {
      _user = updated;
    }
    notifyListeners();
  }
}