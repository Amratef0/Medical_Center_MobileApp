import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/user_model.dart';
import '../repositories/users_repository.dart';

enum UsersStatus { initial, loading, loaded, error }

class UsersState {
  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final UsersStatus status;
  final List<UserModel> users;
  final String? errorMessage;
  final bool isSubmitting;

  UsersState copyWith({
    UsersStatus? status,
    List<UserModel>? users,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "المستخدمين" (للأدمن بس).
class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._repository) : super(const UsersState());

  final UsersRepository _repository;

  Future<void> loadUsers({String search = ''}) async {
    emit(state.copyWith(status: UsersStatus.loading, errorMessage: null));
    try {
      final users = await _repository.getUsers(search: search);
      emit(state.copyWith(status: UsersStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: UsersStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createUser(name: name, email: email, password: password, role: role);
      emit(state.copyWith(isSubmitting: false));
      await loadUsers();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteUser(id);
      emit(state.copyWith(isSubmitting: false));
      await loadUsers();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
