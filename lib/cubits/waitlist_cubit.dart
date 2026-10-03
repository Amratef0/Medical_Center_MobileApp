import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/waitlist_model.dart';
import '../repositories/waitlist_repository.dart';

enum WaitlistStatus { initial, loading, loaded, error }

class WaitlistState {
  const WaitlistState({
    this.status = WaitlistStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final WaitlistStatus status;
  final List<WaitlistModel> items;
  final String? errorMessage;
  final bool isSubmitting;

  WaitlistState copyWith({
    WaitlistStatus? status,
    List<WaitlistModel>? items,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return WaitlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "قائمة الانتظار".
class WaitlistCubit extends Cubit<WaitlistState> {
  WaitlistCubit(this._repository) : super(const WaitlistState());

  final WaitlistRepository _repository;

  Future<void> loadWaitlist({String search = ''}) async {
    emit(state.copyWith(status: WaitlistStatus.loading, errorMessage: null));
    try {
      final items = await _repository.getWaitlist(search: search);
      emit(state.copyWith(status: WaitlistStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: WaitlistStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> addToWaitlist({
    required String patientId,
    String? serviceId,
    String? doctorId,
    String? preferredDate,
    String? notes,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.addToWaitlist(
        patientId: patientId,
        serviceId: serviceId,
        doctorId: doctorId,
        preferredDate: preferredDate,
        notes: notes,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadWaitlist();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> removeFromWaitlist(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteFromWaitlist(id);
      emit(state.copyWith(isSubmitting: false));
      await loadWaitlist();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
