import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/session_model.dart';
import '../repositories/sessions_repository.dart';

enum SessionsStatus { initial, loading, loaded, error }

class SessionsState {
  const SessionsState({
    this.status = SessionsStatus.initial,
    this.sessions = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.statusFilter,
  });

  final SessionsStatus status;
  final List<SessionModel> sessions;
  final String? errorMessage;
  final bool isSubmitting;
  final String? statusFilter; // فلتر SCHEDULED / ATTENDED / MISSED / CANCELED

  SessionsState copyWith({
    SessionsStatus? status,
    List<SessionModel>? sessions,
    String? errorMessage,
    bool? isSubmitting,
    String? statusFilter,
    bool clearFilter = false,
  }) {
    return SessionsState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// المسؤول عن شاشة "الجلسات": جلب القائمة، فلترة، إضافة، تعديل الحالة، حذف.
class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repository) : super(const SessionsState());

  final SessionsRepository _repository;

  Future<void> loadSessions({String? status}) async {
    emit(state.copyWith(
      status: SessionsStatus.loading,
      errorMessage: null,
      statusFilter: status,
      clearFilter: status == null,
    ));
    try {
      final sessions = await _repository.getSessions(status: status);
      emit(state.copyWith(status: SessionsStatus.loaded, sessions: sessions));
    } catch (e) {
      emit(state.copyWith(status: SessionsStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<void> refresh() => loadSessions(status: state.statusFilter);

  Future<bool> createSession({
    required String patientId,
    String? doctorId,
    String? serviceId,
    required String sessionType,
    required String sessionDate,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createSession(
        patientId: patientId,
        doctorId: doctorId,
        serviceId: serviceId,
        sessionType: sessionType,
        sessionDate: sessionDate,
      );
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updateSessionStatus({
    required String id,
    required String status,
    String? absenceReason,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.updateSession(id: id, status: status, absenceReason: absenceReason);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteSession(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteSession(id);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
