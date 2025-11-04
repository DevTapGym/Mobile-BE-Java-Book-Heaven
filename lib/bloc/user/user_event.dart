import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserInfo extends UserEvent {}

class ChangeAvatar extends UserEvent {
  final File avatarPath;

  ChangeAvatar({required this.avatarPath});

  @override
  List<Object?> get props => [avatarPath];
}

class UpdateUser extends UserEvent {
  final String name;
  final String dateOfBirth;
  final String phone;
  final String gender;

  UpdateUser({
    required this.name,
    required this.dateOfBirth,
    required this.phone,
    required this.gender,
  });

  @override
  List<Object?> get props => [name, dateOfBirth, phone, gender];
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
