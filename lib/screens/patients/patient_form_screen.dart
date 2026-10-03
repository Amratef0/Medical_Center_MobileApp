import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_dialogs.dart';
import '../../cubits/patients_cubit.dart';
import '../../models/patient_model.dart';
import '../../repositories/patients_repository.dart';

/// شاشة واحدة بتستخدم للإضافة والتعديل مع بعض.
/// لو [existingPatient] مبعوت معناه إحنا في وضع التعديل.
class PatientFormScreen extends StatelessWidget {
  const PatientFormScreen({super.key, this.existingPatient});

  final PatientModel? existingPatient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsCubit(PatientsRepository()),
      child: _PatientFormView(existingPatient: existingPatient),
    );
  }
}

class _PatientFormView extends StatefulWidget {
  const _PatientFormView({this.existingPatient});

  final PatientModel? existingPatient;

  @override
  State<_PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<_PatientFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  String? _gender;

  bool get _isEditing => widget.existingPatient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPatient;
    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _whatsappController = TextEditingController(text: p?.whatsappNumber ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _gender = p?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<PatientsCubit>();
    bool success;
    if (_isEditing) {
      success = await cubit.updatePatient(
        id: widget.existingPatient!.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );
    } else {
      success = await cubit.createPatient(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) {
      AppDialogs.showSuccess(context, _isEditing ? 'تم تعديل بيانات المريض' : 'تم إضافة المريض بنجاح');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل بيانات المريض' : 'إضافة مريض جديد')),
      body: BlocListener<PatientsCubit, PatientsState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'الاسم الأول'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'اسم العائلة'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'النوع'),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('ذكر')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم التليفون'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الواتساب'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                const SizedBox(height: 24),
                BlocBuilder<PatientsCubit, PatientsState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isSubmitting ? null : _submit,
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة المريض'),
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
