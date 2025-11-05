import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserInfo extends UserEvent {}

class ChangeAvatar extends UserEvent {
  final int id;
  final File avatarPath;

  ChangeAvatar({required this.id, required this.avatarPath});

  @override
  List<Object?> get props => [id, avatarPath];
}

class UpdateUser extends UserEvent {
  final int id;
  final int customerId;
  final String name;
  final String dateOfBirth;
  final String phone;
  final String gender;
  final String avatar;
  final String email;

  UpdateUser({
    required this.id,
    required this.customerId,
    required this.name,
    required this.dateOfBirth,
    required this.phone,
    required this.gender,
    required this.avatar,
    required this.email,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    dateOfBirth,
    phone,
    gender,
    avatar,
    email,
  ];
}

class ChangePassword extends UserEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}
