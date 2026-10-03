import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/treatment_plan_model.dart';
import '../repositories/treatment_plans_repository.dart';

enum TreatmentPlansStatus { initial, loading, loaded, error }

class TreatmentPlansState {
  const TreatmentPlansState({
    this.status = TreatmentPlansStatus.initial,
    this.plans = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final TreatmentPlansStatus status;
  final List<TreatmentPlanModel> plans;
  final String? errorMessage;
  final bool isSubmitting;

  TreatmentPlansState copyWith({
    TreatmentPlansStatus? status,
    List<TreatmentPlanModel>? plans,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return TreatmentPlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "خطط العلاج".
class TreatmentPlansCubit extends Cubit<TreatmentPlansState> {
  TreatmentPlansCubit(this._repository) : super(const TreatmentPlansState());

  final TreatmentPlansRepository _repository;

  Future<void> loadPlans({String search = ''}) async {
    emit(state.copyWith(status: TreatmentPlansStatus.loading, errorMessage: null));
    try {
      final plans = await _repository.getPlans(search: search);
      emit(state.copyWith(status: TreatmentPlansStatus.loaded, plans: plans));
    } catch (e) {
      emit(state.copyWith(status: TreatmentPlansStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createPlan({
    required String patientId,
    String? doctorId,
    required int totalSessions,
    String? frequency,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createPlan(
        patientId: patientId,
        doctorId: doctorId,
        totalSessions: totalSessions,
        frequency: frequency,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadPlans();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deletePlan(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deletePlan(id);
      emit(state.copyWith(isSubmitting: false));
      await loadPlans();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
