import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User userData;
  final String? message;

  UserLoaded({required this.userData, this.message});

  @override
  List<Object?> get props => [userData];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}
