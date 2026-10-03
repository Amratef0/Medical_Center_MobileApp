import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/patient_model.dart';
import '../repositories/patients_repository.dart';

enum PatientsStatus { initial, loading, loaded, error }

class PatientsState {
  const PatientsState({
    this.status = PatientsStatus.initial,
    this.patients = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final PatientsStatus status;
  final List<PatientModel> patients;
  final String? errorMessage;
  final bool isSubmitting; // true وهو بيعمل create/update/delete

  PatientsState copyWith({
    PatientsStatus? status,
    List<PatientModel>? patients,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن كل حالة شاشة "المرضى": جلب القائمة، بحث، إضافة، تعديل، حذف.
class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit(this._repository) : super(const PatientsState());

  final PatientsRepository _repository;
  String _currentSearch = '';

  Future<void> loadPatients({String search = ''}) async {
    _currentSearch = search;
    emit(state.copyWith(status: PatientsStatus.loading, errorMessage: null));
    try {
      final patients = await _repository.getPatients(search: search);
      emit(state.copyWith(status: PatientsStatus.loaded, patients: patients));
    } catch (e) {
      emit(state.copyWith(status: PatientsStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<void> refresh() => loadPatients(search: _currentSearch);

  Future<bool> createPatient({
    required String firstName,
    required String lastName,
    String? gender,
    String? dateOfBirth,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? address,
    String? notes,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createPatient(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phone: phone,
        whatsappNumber: whatsappNumber,
        email: email,
        address: address,
        notes: notes,
      );
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updatePatient({
    required String id,
    required String firstName,
    required String lastName,
    String? gender,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? address,
    String? status,
    String? notes,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.updatePatient(
        id: id,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        phone: phone,
        whatsappNumber: whatsappNumber,
        email: email,
        address: address,
        status: status,
        notes: notes,
      );
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deletePatient(id);
      emit(state.copyWith(isSubmitting: false));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
