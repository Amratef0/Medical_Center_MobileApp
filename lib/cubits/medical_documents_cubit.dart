import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/medical_document_model.dart';
import '../repositories/medical_documents_repository.dart';

enum MedicalDocumentsStatus { initial, loading, loaded, error }

class MedicalDocumentsState {
  const MedicalDocumentsState({
    this.status = MedicalDocumentsStatus.initial,
    this.documents = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final MedicalDocumentsStatus status;
  final List<MedicalDocumentModel> documents;
  final String? errorMessage;
  final bool isSubmitting;

  MedicalDocumentsState copyWith({
    MedicalDocumentsStatus? status,
    List<MedicalDocumentModel>? documents,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return MedicalDocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن مستندات مريض معيّن (روشتات / أشعة / تقارير).
class MedicalDocumentsCubit extends Cubit<MedicalDocumentsState> {
  MedicalDocumentsCubit(this._repository) : super(const MedicalDocumentsState());

  final MedicalDocumentsRepository _repository;
  String? _patientId;

  Future<void> loadDocuments(String patientId) async {
    _patientId = patientId;
    emit(state.copyWith(status: MedicalDocumentsStatus.loading, errorMessage: null));
    try {
      final docs = await _repository.getDocumentsByPatient(patientId);
      emit(state.copyWith(status: MedicalDocumentsStatus.loaded, documents: docs));
    } catch (e) {
      emit(state.copyWith(status: MedicalDocumentsStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createDocument({
    String? doctorId,
    required String type,
    required String title,
    String? content,
    String? notes,
  }) async {
    if (_patientId == null) return false;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createDocument(
        patientId: _patientId!,
        doctorId: doctorId,
        type: type,
        title: title,
        content: content,
        notes: notes,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadDocuments(_patientId!);
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    if (_patientId == null) return false;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deleteDocument(id);
      emit(state.copyWith(isSubmitting: false));
      await loadDocuments(_patientId!);
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
