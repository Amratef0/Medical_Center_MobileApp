/// نموذج الخدمة - نفس service.entity.ts
class ServiceModel {
  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    this.price,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double? price;
  final bool isActive;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      durationMinutes: json['duration_minutes'] ?? 30,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      isActive: json['is_active'] ?? true,
    );
  }
}
