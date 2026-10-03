/// نموذج مواعيد عمل الدكتور - نفس doctor-availability.entity.ts
class DoctorAvailabilityModel {
  DoctorAvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotCapacity,
    required this.isActive,
  });

  final String id;
  final String doctorId;
  final int dayOfWeek; // 0 = الأحد .. 6 = السبت
  final String startTime;
  final String endTime;
  final int slotCapacity;
  final bool isActive;

  static const List<String> dayNames = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  String get dayName => (dayOfWeek >= 0 && dayOfWeek < 7) ? dayNames[dayOfWeek] : '-';

  factory DoctorAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityModel(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      slotCapacity: json['slot_capacity'] ?? 1,
      isActive: json['is_active'] ?? true,
    );
  }
}
