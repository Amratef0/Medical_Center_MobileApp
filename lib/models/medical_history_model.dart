/// نموذج التاريخ الطبي - نفس medical-history.entity.ts
class MedicalHistoryModel {
  MedicalHistoryModel({
    this.allergies,
    this.chronicDiseases,
    this.medications,
    this.surgeries,
    this.notes,
  });

  final String? allergies;
  final String? chronicDiseases;
  final String? medications;
  final String? surgeries;
  final String? notes;

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryModel(
      allergies: json['allergies'],
      chronicDiseases: json['chronic_diseases'],
      medications: json['medications'],
      surgeries: json['surgeries'],
      notes: json['notes'],
    );
  }
}
