import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../repositories/reporting_repository.dart';

enum ReportingStatus { initial, loading, loaded, error }

class ReportingState {
  const ReportingState({
    this.status = ReportingStatus.initial,
    this.dailyReport,
    this.errorMessage,
  });

  final ReportingStatus status;
  final Map<String, dynamic>? dailyReport;
  final String? errorMessage;

  ReportingState copyWith({
    ReportingStatus? status,
    Map<String, dynamic>? dailyReport,
    String? errorMessage,
  }) {
    return ReportingState(
      status: status ?? this.status,
      dailyReport: dailyReport ?? this.dailyReport,
      errorMessage: errorMessage,
    );
  }
}

/// المسؤول عن شاشة "التقارير".
class ReportingCubit extends Cubit<ReportingState> {
  ReportingCubit(this._repository) : super(const ReportingState());

  final ReportingRepository _repository;

  Future<void> loadDailyReport({String? date}) async {
    emit(state.copyWith(status: ReportingStatus.loading, errorMessage: null));
    try {
      final report = await _repository.getDailyReport(date: date);
      emit(state.copyWith(status: ReportingStatus.loaded, dailyReport: report));
    } catch (e) {
      emit(state.copyWith(status: ReportingStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }
}
