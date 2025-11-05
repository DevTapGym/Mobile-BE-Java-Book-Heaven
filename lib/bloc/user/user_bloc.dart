import 'package:flutter/widgets.dart';
import 'package:heaven_book_app/bloc/user/user_event.dart';
import 'package:heaven_book_app/bloc/user/user_state.dart';
import 'package:heaven_book_app/services/auth_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService authService;

  UserBloc(this.authService) : super(UserInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
    on<ChangePassword>(_onChangePassword);
    on<UpdateUser>(_onUpdateUser);
    on<ChangeAvatar>(_onChangeAvatar);
  }

  Future<void> _onLoadUserInfo(
    LoadUserInfo event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final userInfo = await authService.getCurrentUser();
      debugPrint('Loaded user info: $userInfo');
      emit(UserLoaded(userData: userInfo));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;

    emit(UserLoading());
    try {
      String? email;
      if (currentState is UserLoaded) {
        email = currentState.userData.email;
      }
      debugPrint('User email for password change: $email');

      await authService.changePassword(
        event.currentPassword,
        event.newPassword,
        email ?? '', // fallback nếu null
      );

      emit(
        UserLoaded(
          userData: await authService.getCurrentUser(),
          message: "Password changed successfully",
        ),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final resultUpdateUser = await authService.updateInfoUser(
        event.id,
        name: event.name,
        phone: event.phone,
        avatar: event.avatar,
        email: event.email,
      );

      final resultUpdateCustomer = await authService.updateCustomer(
        event.customerId,
        event.name,
        event.phone,
        event.email,
        event.dateOfBirth,
        event.gender,
      );

      if (resultUpdateUser && resultUpdateCustomer) {
        emit(
          UserLoaded(
            userData: await authService.getCurrentUser(),
            message: "User information updated successfully",
          ),
        );
      } else {
        emit(UserError("Failed to update user information"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onChangeAvatar(
    ChangeAvatar event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final updatedUser = await authService.uploadAvatar(event.avatarPath);

      if (updatedUser.isEmpty) {
        emit(UserError("Failed to upload avatar"));
        return;
      }

      final resultUpdateUser = await authService.updateInfoUser(
        event.id,
        name: event.name,
        phone: event.phone,
        email: event.email,
        avatar: updatedUser,
      );

      if (resultUpdateUser) {
        emit(
          UserLoaded(
            userData: await authService.getCurrentUser(),
            message: "Avatar updated successfully",
          ),
        );
      } else {
        emit(UserError("Failed to update user information"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
