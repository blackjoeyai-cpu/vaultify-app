import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({required this.id, required this.createdAt, this.lastLoginAt});

  User copyWith({String? id, DateTime? createdAt, DateTime? lastLoginAt}) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, lastLoginAt];
}
