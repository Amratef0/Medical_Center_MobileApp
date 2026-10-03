import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/package_model.dart';
import '../repositories/packages_repository.dart';

enum PackagesStatus { initial, loading, loaded, error }

class PackagesState {
  const PackagesState({
    this.status = PackagesStatus.initial,
    this.packages = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final PackagesStatus status;
  final List<PackageModel> packages;
  final String? errorMessage;
  final bool isSubmitting;

  PackagesState copyWith({
    PackagesStatus? status,
    List<PackageModel>? packages,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return PackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "الباقات".
class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit(this._repository) : super(const PackagesState());

  final PackagesRepository _repository;

  Future<void> loadPackages() async {
    emit(state.copyWith(status: PackagesStatus.loading, errorMessage: null));
    try {
      final packages = await _repository.getPackages();
      emit(state.copyWith(status: PackagesStatus.loaded, packages: packages));
    } catch (e) {
      emit(state.copyWith(status: PackagesStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createPackage({
    required String name,
    String? description,
    required int totalSessions,
    int? expiryDays,
    double? price,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createPackage(
        name: name,
        description: description,
        totalSessions: totalSessions,
        expiryDays: expiryDays,
        price: price,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadPackages();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deletePackage(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.deletePackage(id);
      emit(state.copyWith(isSubmitting: false));
      await loadPackages();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> assignToPatient({required String patientId, required String packageId}) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.assignPackageToPatient(patientId: patientId, packageId: packageId);
      emit(state.copyWith(isSubmitting: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
