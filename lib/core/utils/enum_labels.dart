import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// كل الـ enums بتاعت الباك اند وترجمتها العربية + لونها،
/// عشان نعرضها بشكل موحّد في كل شاشات الابليكيشن.
class EnumLabels {
  EnumLabels._();

  static const Map<String, String> patientStatus = {
    'PENDING_ASSESSMENT': 'بانتظار التقييم',
    'ASSESSMENT_COMPLETED': 'تم التقييم',
    'ASSESSMENT_DROPOFF': 'انسحب قبل التقييم',
  };

  static const Map<String, String> sessionStatus = {
    'SCHEDULED': 'محجوزة',
    'ATTENDED': 'حضر',
    'MISSED': 'غاب',
    'CANCELED': 'ملغية',
  };

  static const Map<String, String> sessionType = {
    'ASSESSMENT': 'تقييم',
    'TREATMENT': 'علاج',
    'FOLLOWUP': 'متابعة',
  };

  static const Map<String, String> invoiceStatus = {
    'PENDING': 'قيد الانتظار',
    'PAID': 'مدفوعة',
    'CANCELLED': 'ملغية',
  };

  static const Map<String, String> paymentStatus = {
    'PAID': 'مدفوع',
    'PENDING': 'قيد الانتظار',
    'REJECTED': 'مرفوض',
  };

  static const Map<String, String> paymentMethod = {
    'CASH': 'كاش',
    'CARD': 'بطاقة',
    'BANK_TRANSFER': 'تحويل بنكي',
    'OTHER': 'أخرى',
  };

  static const Map<String, String> followUpType = {
    'DROP_OFF': 'انسحاب',
    'MISSED_SESSION': 'جلسة فائتة',
    'RENEWAL': 'تجديد',
  };

  static const Map<String, String> followUpStatus = {
    'PENDING': 'قيد الانتظار',
    'RESOLVED': 'تم الحل',
    'CANCELLED': 'ملغي',
  };

  static const Map<String, String> patientPackageStatus = {
    'ACTIVE': 'فعالة',
    'EXPIRED': 'منتهية',
    'EXHAUSTED': 'مستنفدة',
    'SUSPENDED': 'موقوفة',
  };

  static const Map<String, String> userRole = {
    'RECEPTIONIST': 'استقبال',
    'OPERATIONS_MANAGER': 'مدير عمليات',
    'DOCTOR': 'دكتور',
    'FINANCE': 'مالية',
    'CUSTOMER_SUPPORT': 'دعم العملاء',
    'ADMIN': 'أدمن',
  };

  static const Map<String, String> documentType = {
    'PRESCRIPTION': 'روشتة',
    'XRAY': 'أشعة',
    'REPORT': 'تقرير',
  };

  /// بيرجع الترجمة العربية، ولو مش موجودة بيرجع نفس القيمة زي ما هي.
  static String label(Map<String, String> map, String? key) {
    if (key == null) return '-';
    return map[key] ?? key;
  }

  /// لون الحالة (نجاح / تحذير / خطر) بناءً على النص
  static Color statusColor(String? status) {
    switch (status) {
      case 'ATTENDED':
      case 'PAID':
      case 'ASSESSMENT_COMPLETED':
      case 'RESOLVED':
      case 'ACTIVE':
        return AppColors.success;
      case 'PENDING':
      case 'SCHEDULED':
      case 'PENDING_ASSESSMENT':
      case 'SUSPENDED':
        return AppColors.warning;
      case 'MISSED':
      case 'CANCELED':
      case 'CANCELLED':
      case 'REJECTED':
      case 'ASSESSMENT_DROPOFF':
      case 'EXPIRED':
      case 'EXHAUSTED':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}
