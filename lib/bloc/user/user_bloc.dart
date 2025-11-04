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
      emit(UserLoaded(userData: userInfo));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await authService.changePassword(
        event.currentPassword,
        event.newPassword,
        event.newPasswordConfirmation,
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
      final result = await authService.updateInfoUser(
        event.name,
        event.dateOfBirth,
        event.phone,
        event.gender,
      );

      if (result) {
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
      emit(
        UserLoaded(
          userData: updatedUser,
          message: "Avatar changed successfully",
        ),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
