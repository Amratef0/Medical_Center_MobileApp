import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/package_model.dart';
import '../models/medical_history_model.dart';
import '../repositories/patients_repository.dart';
import '../repositories/sessions_repository.dart';
import '../repositories/treatment_plans_repository.dart';
import '../repositories/packages_repository.dart';

enum PatientDetailStatus { initial, loading, loaded, error }

/// شاشة تفاصيل المريض بتحتاج بيانات من أكتر من مكان (المريض نفسه + جلساته
/// + خطط علاجه + باقاته + تاريخه الطبي)، فعملنا لها Cubit خاص يجمعهم مع بعض.
class PatientDetailState {
  const PatientDetailState({
    this.status = PatientDetailStatus.initial,
    this.patient,
    this.sessions = const [],
    this.treatmentPlans = const [],
    this.patientPackages = const [],
    this.medicalHistory,
    this.errorMessage,
    this.isSavingHistory = false,
  });

  final PatientDetailStatus status;
  final PatientModel? patient;
  final List<SessionModel> sessions;
  final List<TreatmentPlanModel> treatmentPlans;
  final List<PatientPackageModel> patientPackages;
  final MedicalHistoryModel? medicalHistory;
  final String? errorMessage;
  final bool isSavingHistory;

  PatientDetailState copyWith({
    PatientDetailStatus? status,
    PatientModel? patient,
    List<SessionModel>? sessions,
    List<TreatmentPlanModel>? treatmentPlans,
    List<PatientPackageModel>? patientPackages,
    MedicalHistoryModel? medicalHistory,
    String? errorMessage,
    bool? isSavingHistory,
  }) {
    return PatientDetailState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      sessions: sessions ?? this.sessions,
      treatmentPlans: treatmentPlans ?? this.treatmentPlans,
      patientPackages: patientPackages ?? this.patientPackages,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      errorMessage: errorMessage,
      isSavingHistory: isSavingHistory ?? this.isSavingHistory,
    );
  }
}

class PatientDetailCubit extends Cubit<PatientDetailState> {
  PatientDetailCubit({
    required PatientsRepository patientsRepository,
    required SessionsRepository sessionsRepository,
    required TreatmentPlansRepository treatmentPlansRepository,
    required PackagesRepository packagesRepository,
  })  : _patientsRepository = patientsRepository,
        _sessionsRepository = sessionsRepository,
        _treatmentPlansRepository = treatmentPlansRepository,
        _packagesRepository = packagesRepository,
        super(const PatientDetailState());

  final PatientsRepository _patientsRepository;
  final SessionsRepository _sessionsRepository;
  final TreatmentPlansRepository _treatmentPlansRepository;
  final PackagesRepository _packagesRepository;
  String? _patientId;

  Future<void> loadPatientDetails(String patientId) async {
    _patientId = patientId;
    emit(state.copyWith(status: PatientDetailStatus.loading, errorMessage: null));
    try {
      // بنجيب كل البيانات مع بعض عشان الشاشة تفتح بسرعة
      final results = await Future.wait([
        _patientsRepository.getPatientById(patientId),
        _sessionsRepository.getSessionsByPatient(patientId),
        _treatmentPlansRepository.getPlansByPatient(patientId),
        _packagesRepository.getPatientPackages(patientId),
        _patientsRepository.getMedicalHistory(patientId),
      ]);

      emit(state.copyWith(
        status: PatientDetailStatus.loaded,
        patient: results[0] as PatientModel,
        sessions: results[1] as List<SessionModel>,
        treatmentPlans: results[2] as List<TreatmentPlanModel>,
        patientPackages: results[3] as List<PatientPackageModel>,
        medicalHistory: results[4] as MedicalHistoryModel?,
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientDetailStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> saveMedicalHistory({
    String? allergies,
    String? chronicDiseases,
    String? medications,
    String? surgeries,
    String? notes,
  }) async {
    if (_patientId == null) return false;
    emit(state.copyWith(isSavingHistory: true, errorMessage: null));
    try {
      await _patientsRepository.saveMedicalHistory(
        patientId: _patientId!,
        allergies: allergies,
        chronicDiseases: chronicDiseases,
        medications: medications,
        surgeries: surgeries,
        notes: notes,
      );
      final updatedHistory = await _patientsRepository.getMedicalHistory(_patientId!);
      emit(state.copyWith(isSavingHistory: false, medicalHistory: updatedHistory));
      return true;
    } catch (e) {
      emit(state.copyWith(isSavingHistory: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
