import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/scheduling_cubit.dart';
import '../../models/doctor_model.dart';
import '../../repositories/doctors_repository.dart';
import '../../repositories/scheduling_repository.dart';

class SlotFormScreen extends StatelessWidget {
  const SlotFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SchedulingCubit(SchedulingRepository()),
      child: const _SlotFormView(),
    );
  }
}

class _SlotFormView extends StatefulWidget {
  const _SlotFormView();

  @override
  State<_SlotFormView> createState() => _SlotFormViewState();
}

class _SlotFormViewState extends State<_SlotFormView> {
  final _doctorsRepository = DoctorsRepository();
  final _capacityController = TextEditingController(text: '1');

  List<DoctorModel> _doctors = [];
  bool _loadingDoctors = true;
  String? _selectedDoctorId;

  DateTime _date = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _doctorsRepository.getDoctors(limit: 100);
      if (mounted) setState(() { _doctors = doctors; _loadingDoctors = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    final start = _combine(_date, _startTime);
    final end = _combine(_date, _endTime);
    if (!end.isAfter(start)) {
      AppDialogs.showError(context, 'وقت النهاية لازم يكون بعد وقت البداية');
      return;
    }

    final success = await context.read<SchedulingCubit>().createSlot(
          doctorId: _selectedDoctorId,
          startTime: start.toIso8601String(),
          endTime: end.toIso8601String(),
          capacity: int.tryParse(_capacityController.text) ?? 1,
        );
    if (!mounted) return;
    if (success) {
      AppDialogs.showSuccess(context, 'تم إضافة الموعد بنجاح');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة معاد')),
      body: BlocListener<SchedulingCubit, SchedulingState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        child: _loadingDoctors
            ? const LoadingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDoctorId,
                      decoration: const InputDecoration(labelText: 'الدكتور (اختياري)'),
                      isExpanded: true,
                      items: _doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                      onChanged: (value) => setState(() => _selectedDoctorId = value),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'التاريخ'),
                        child: Text('${_date.year}/${_date.month}/${_date.day}'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: _startTime);
                              if (picked != null) setState(() => _startTime = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'من الساعة'),
                              child: Text(_startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: _endTime);
                              if (picked != null) setState(() => _endTime = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'إلى الساعة'),
                              child: Text(_endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعة (عدد المرضى)'),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<SchedulingCubit, SchedulingState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isSubmitting ? null : _submit,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('إضافة الموعد'),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
