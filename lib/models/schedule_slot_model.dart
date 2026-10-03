/// نموذج معاد الجدولة (Slot) - نفس schedule-slot.entity.ts
class ScheduleSlotModel {
  ScheduleSlotModel({
    required this.id,
    this.doctorId,
    this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
    this.type,
    required this.isAvailable,
  });

  final String id;
  final String? doctorId;
  final String? serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;
  final String? type;
  final bool isAvailable;

  int get remainingCapacity => capacity - bookedCount;

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotModel(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'],
      serviceId: json['service_id'],
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      capacity: json['capacity'] ?? 1,
      bookedCount: json['booked_count'] ?? 0,
      type: json['type'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}
