import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/follow_up_model.dart';
import '../repositories/follow_ups_repository.dart';

enum FollowUpsStatus { initial, loading, loaded, error }

class FollowUpsState {
  const FollowUpsState({
    this.status = FollowUpsStatus.initial,
    this.followUps = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final FollowUpsStatus status;
  final List<FollowUpModel> followUps;
  final String? errorMessage;
  final bool isSubmitting;

  FollowUpsState copyWith({
    FollowUpsStatus? status,
    List<FollowUpModel>? followUps,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return FollowUpsState(
      status: status ?? this.status,
      followUps: followUps ?? this.followUps,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "المتابعات".
class FollowUpsCubit extends Cubit<FollowUpsState> {
  FollowUpsCubit(this._repository) : super(const FollowUpsState());

  final FollowUpsRepository _repository;

  Future<void> loadFollowUps({String? status}) async {
    emit(state.copyWith(status: FollowUpsStatus.loading, errorMessage: null));
    try {
      final followUps = await _repository.getFollowUps(status: status);
      emit(state.copyWith(status: FollowUpsStatus.loaded, followUps: followUps));
    } catch (e) {
      emit(state.copyWith(status: FollowUpsStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> updateStatus({required String id, required String status}) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.updateStatus(id: id, status: status);
      emit(state.copyWith(isSubmitting: false));
      await loadFollowUps();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteFollowUp(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteFollowUp(id);
      emit(state.copyWith(isSubmitting: false));
      await loadFollowUps();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
