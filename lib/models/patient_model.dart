/// نموذج المريض - نفس patient.entity.ts في الباك اند.
class PatientModel {
  PatientModel({
    required this.id,
    required this.patientCode,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.phone,
    this.whatsappNumber,
    this.emergencyContact,
    this.email,
    required this.status,
    this.registrationDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String patientCode;
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? phone;
  final String? whatsappNumber;
  final String? emergencyContact;
  final String? email;
  final String status;
  final DateTime? registrationDate;
  final String? notes;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName';

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      patientCode: json['patient_code'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
      address: json['address'],
      phone: json['phone'],
      whatsappNumber: json['whatsapp_number'],
      emergencyContact: json['emergency_contact'],
      email: json['email'],
      status: json['status'] ?? 'PENDING_ASSESSMENT',
      registrationDate:
          json['registration_date'] != null ? DateTime.tryParse(json['registration_date']) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
