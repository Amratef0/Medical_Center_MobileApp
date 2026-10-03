import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/schedule_slot_model.dart';
import '../repositories/scheduling_repository.dart';

enum SchedulingStatus { initial, loading, loaded, error }

class SchedulingState {
  const SchedulingState({
    this.status = SchedulingStatus.initial,
    this.slots = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final SchedulingStatus status;
  final List<ScheduleSlotModel> slots;
  final String? errorMessage;
  final bool isSubmitting;

  SchedulingState copyWith({
    SchedulingStatus? status,
    List<ScheduleSlotModel>? slots,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return SchedulingState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "الجدولة": جلب المواعيد المتاحة، إضافة معاد جديد، حجز/إلغاء.
class SchedulingCubit extends Cubit<SchedulingState> {
  SchedulingCubit(this._repository) : super(const SchedulingState());

  final SchedulingRepository _repository;
  String? _doctorFilter;
  String? _dateFilter;

  Future<void> loadSlots({String? doctorId, String? date}) async {
    _doctorFilter = doctorId;
    _dateFilter = date;
    emit(state.copyWith(status: SchedulingStatus.loading, errorMessage: null));
    try {
      final slots = await _repository.getSlots(doctorId: doctorId, date: date);
      emit(state.copyWith(status: SchedulingStatus.loaded, slots: slots));
    } catch (e) {
      emit(state.copyWith(status: SchedulingStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<void> refresh() => loadSlots(doctorId: _doctorFilter, date: _dateFilter);

  Future<bool> createSlot({
    String? doctorId,
    String? serviceId,
    required String startTime,
    required String endTime,
    int capacity = 1,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createSlot(
        doctorId: doctorId,
        serviceId: serviceId,
        startTime: startTime,
        endTime: endTime,
        capacity: capacity,
      );
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteSlot(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteSlot(id);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> bookSlot(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.bookSlot(id);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> cancelBooking(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.cancelBooking(id);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
