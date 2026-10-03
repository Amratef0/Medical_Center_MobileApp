import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

/// الحالة الخاصة بتسجيل الدخول/الخروج، بيتحطّ فوق الابليكيشن كله
/// عشان نعرف نوجّه المستخدم للوجين أو للداشبورد.
class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  /// بيتنادي أول ما الابليكيشن يفتح، عشان يشوف لو فيه يوزر مسجل دخول قبل كده.
  Future<void> checkAuthStatus() async {
    final user = await _authRepository.getSavedUser();
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.login(email: email, password: password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
