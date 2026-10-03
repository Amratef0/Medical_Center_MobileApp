import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/doctor_availability_model.dart';
import '../repositories/doctors_repository.dart';

enum DoctorAvailabilityStatus { initial, loading, loaded, error }

class DoctorAvailabilityState {
  const DoctorAvailabilityState({
    this.status = DoctorAvailabilityStatus.initial,
    this.availability = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final DoctorAvailabilityStatus status;
  final List<DoctorAvailabilityModel> availability;
  final String? errorMessage;
  final bool isSubmitting;

  DoctorAvailabilityState copyWith({
    DoctorAvailabilityStatus? status,
    List<DoctorAvailabilityModel>? availability,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return DoctorAvailabilityState(
      status: status ?? this.status,
      availability: availability ?? this.availability,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن مواعيد عمل دكتور معيّن (أيام وساعات الشغل بتاعته).
class DoctorAvailabilityCubit extends Cubit<DoctorAvailabilityState> {
  DoctorAvailabilityCubit(this._repository) : super(const DoctorAvailabilityState());

  final DoctorsRepository _repository;
  String? _doctorId;

  Future<void> loadAvailability(String doctorId) async {
    _doctorId = doctorId;
    emit(state.copyWith(status: DoctorAvailabilityStatus.loading, errorMessage: null));
    try {
      final availability = await _repository.getAvailability(doctorId);
      emit(state.copyWith(status: DoctorAvailabilityStatus.loaded, availability: availability));
    } catch (e) {
      emit(state.copyWith(status: DoctorAvailabilityStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> addAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotCapacity = 1,
  }) async {
    if (_doctorId == null) return false;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.addAvailability(
        doctorId: _doctorId!,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        slotCapacity: slotCapacity,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadAvailability(_doctorId!);
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
