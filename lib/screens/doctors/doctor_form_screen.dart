import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_dialogs.dart';
import '../../cubits/doctors_cubit.dart';
import '../../models/doctor_model.dart';
import '../../repositories/doctors_repository.dart';

/// شاشة واحدة بتستخدم للإضافة والتعديل مع بعض.
/// لو [existingDoctor] مبعوت معناه إحنا في وضع التعديل.
class DoctorFormScreen extends StatelessWidget {
  const DoctorFormScreen({super.key, this.existingDoctor});

  final DoctorModel? existingDoctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorsCubit(DoctorsRepository()),
      child: _DoctorFormView(existingDoctor: existingDoctor),
    );
  }
}

class _DoctorFormView extends StatefulWidget {
  const _DoctorFormView({this.existingDoctor});

  final DoctorModel? existingDoctor;

  @override
  State<_DoctorFormView> createState() => _DoctorFormViewState();
}

class _DoctorFormViewState extends State<_DoctorFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late bool _isActive;

  bool get _isEditing => widget.existingDoctor != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDoctor;
    _nameController = TextEditingController(text: d?.name ?? '');
    _specializationController = TextEditingController(text: d?.specialization ?? '');
    _phoneController = TextEditingController(text: d?.phone ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _isActive = d?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<DoctorsCubit>();
    bool success;
    if (_isEditing) {
      success = await cubit.updateDoctor(
        id: widget.existingDoctor!.id,
        name: _nameController.text.trim(),
        specialization: _specializationController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        isActive: _isActive,
      );
    } else {
      success = await cubit.createDoctor(
        name: _nameController.text.trim(),
        specialization: _specializationController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) {
      AppDialogs.showSuccess(context, _isEditing ? 'تم تعديل بيانات الدكتور' : 'تم إضافة الدكتور بنجاح');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل بيانات الدكتور' : 'إضافة دكتور')),
      body: BlocListener<DoctorsCubit, DoctorsState>(
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الدكتور'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(labelText: 'التخصص'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم التليفون'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('نشط'),
                    subtitle: const Text('الدكتور غير النشط مش هيظهر في اختيارات الحجز'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
                const SizedBox(height: 24),
                BlocBuilder<DoctorsCubit, DoctorsState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isSubmitting ? null : _submit,
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة'),
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
