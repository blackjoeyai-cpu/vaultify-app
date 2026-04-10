import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum PasswordCategory {
  social,
  financial,
  work,
  others;

  String get displayName {
    switch (this) {
      case PasswordCategory.social:
        return 'Social';
      case PasswordCategory.financial:
        return 'Financial';
      case PasswordCategory.work:
        return 'Work';
      case PasswordCategory.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case PasswordCategory.social:
        return Icons.people;
      case PasswordCategory.financial:
        return Icons.account_balance;
      case PasswordCategory.work:
        return Icons.work;
      case PasswordCategory.others:
        return Icons.folder;
    }
  }

  Color get color {
    switch (this) {
      case PasswordCategory.social:
        return AppTheme.socialColor;
      case PasswordCategory.financial:
        return AppTheme.financialColor;
      case PasswordCategory.work:
        return AppTheme.workColor;
      case PasswordCategory.others:
        return AppTheme.othersColor;
    }
  }
}

class PasswordEntry extends Equatable {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final PasswordCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    PasswordCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    username,
    password,
    url,
    notes,
    category,
    createdAt,
    updatedAt,
    isFavorite,
  ];
}
