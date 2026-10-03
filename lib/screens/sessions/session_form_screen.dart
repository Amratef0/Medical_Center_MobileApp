import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/sessions_cubit.dart';
import '../../models/doctor_model.dart';
import '../../models/patient_model.dart';
import '../../repositories/doctors_repository.dart';
import '../../repositories/patients_repository.dart';
import '../../repositories/sessions_repository.dart';

class SessionFormScreen extends StatelessWidget {
  const SessionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionsCubit(SessionsRepository()),
      child: const _SessionFormView(),
    );
  }
}

class _SessionFormView extends StatefulWidget {
  const _SessionFormView();

  @override
  State<_SessionFormView> createState() => _SessionFormViewState();
}

class _SessionFormViewState extends State<_SessionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _patientsRepository = PatientsRepository();
  final _doctorsRepository = DoctorsRepository();

  List<PatientModel> _patients = [];
  List<DoctorModel> _doctors = [];
  bool _loadingOptions = true;

  String? _selectedPatientId;
  String? _selectedDoctorId;
  String _sessionType = 'TREATMENT';
  DateTime _sessionDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final patients = await _patientsRepository.getPatients(limit: 100);
      final doctors = await _doctorsRepository.getDoctors(limit: 100);
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _doctors = doctors;
        _loadingOptions = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_sessionDate));
    if (time == null) return;
    setState(() {
      _sessionDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      AppDialogs.showError(context, 'لازم تختار المريض');
      return;
    }

    final success = await context.read<SessionsCubit>().createSession(
          patientId: _selectedPatientId!,
          doctorId: _selectedDoctorId,
          sessionType: _sessionType,
          sessionDate: _sessionDate.toIso8601String(),
        );
    if (!mounted) return;
    if (success) {
      AppDialogs.showSuccess(context, 'تم إضافة الجلسة بنجاح');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة جلسة')),
      body: BlocListener<SessionsCubit, SessionsState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        child: _loadingOptions
            ? const LoadingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPatientId,
                        decoration: const InputDecoration(labelText: 'المريض'),
                        isExpanded: true,
                        items: _patients
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedPatientId = value),
                        validator: (v) => v == null ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDoctorId,
                        decoration: const InputDecoration(labelText: 'الدكتور (اختياري)'),
                        isExpanded: true,
                        items: _doctors
                            .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedDoctorId = value),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _sessionType,
                        decoration: const InputDecoration(labelText: 'نوع الجلسة'),
                        items: const [
                          DropdownMenuItem(value: 'ASSESSMENT', child: Text('تقييم')),
                          DropdownMenuItem(value: 'TREATMENT', child: Text('علاج')),
                          DropdownMenuItem(value: 'FOLLOWUP', child: Text('متابعة')),
                        ],
                        onChanged: (value) => setState(() => _sessionType = value!),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: _pickDateTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'ميعاد الجلسة'),
                          child: Text(
                            '${_sessionDate.year}/${_sessionDate.month}/${_sessionDate.day} - ${_sessionDate.hour}:${_sessionDate.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<SessionsCubit, SessionsState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isSubmitting ? null : _submit,
                            child: state.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('إضافة الجلسة'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
