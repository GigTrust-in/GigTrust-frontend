import '../models/role.dart';

class User {
  final String name;
  final String email;
  final Role role;
  final String? avatarUrl;
  final String? gender;
  final String? skills;

  User({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.gender,
    this.skills,
  });

  User copyWith({
    String? name,
    String? email,
    Role? role,
    String? avatarUrl,
    String? gender,
    String? skills,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      skills: skills ?? this.skills,
    );
  }
}