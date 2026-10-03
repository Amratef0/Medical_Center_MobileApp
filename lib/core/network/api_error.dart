import 'package:dio/dio.dart';

/// بياخد أي error من Dio ويحوله لرسالة عربية مفهومة نعرضها للمستخدم.
String extractErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    // الباك اند (Nest ValidationPipe) بيرجع الرسالة في data['message']
    if (data is Map && data['message'] != null) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      return message.toString();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'الاتصال بالسيرفر بطيء، حاول تاني';
      case DioExceptionType.connectionError:
        return 'مش قادر أوصل للسيرفر، اتأكد إن الباك اند شغال والرابط صح';
      default:
        return 'حصل خطأ غير متوقع، حاول تاني';
    }
  }
  return error.toString();
}
