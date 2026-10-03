import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/doctor_model.dart';
import '../repositories/doctors_repository.dart';

enum DoctorsStatus { initial, loading, loaded, error }

class DoctorsState {
  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.doctors = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final DoctorsStatus status;
  final List<DoctorModel> doctors;
  final String? errorMessage;
  final bool isSubmitting;

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<DoctorModel>? doctors,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return DoctorsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "الأطباء": جلب القائمة، إضافة، تعديل، حذف.
class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit(this._repository) : super(const DoctorsState());

  final DoctorsRepository _repository;

  Future<void> loadDoctors({String search = ''}) async {
    emit(state.copyWith(status: DoctorsStatus.loading, errorMessage: null));
    try {
      final doctors = await _repository.getDoctors(search: search);
      emit(state.copyWith(status: DoctorsStatus.loaded, doctors: doctors));
    } catch (e) {
      emit(state.copyWith(status: DoctorsStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createDoctor({
    required String name,
    String? specialization,
    String? phone,
    String? email,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createDoctor(
        name: name,
        specialization: specialization,
        phone: phone,
        email: email,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadDoctors();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updateDoctor({
    required String id,
    required String name,
    String? specialization,
    String? phone,
    String? email,
    bool? isActive,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.updateDoctor(
        id: id,
        name: name,
        specialization: specialization,
        phone: phone,
        email: email,
        isActive: isActive,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadDoctors();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteDoctor(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteDoctor(id);
      emit(state.copyWith(isSubmitting: false));
      await loadDoctors();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
