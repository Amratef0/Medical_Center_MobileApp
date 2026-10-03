/// ثوابت الابليكيشن. غيّر [baseUrl] هنا بس عشان توصل للباك اند بتاعك.
class AppConstants {
  AppConstants._();

  /// رابط الباك اند بتاع NestJS.
  /// - 10.0.2.2 هي بوابة محاكي أندرويد اللي بتودي على localhost بتاع الكمبيوتر
  ///   (لو بتجرب على محاكي، متستخدمش localhost هنا، مش هيشتغل).
  /// - المسار الرسمي هو /api/v1 لأن الباك اند معمول عليه setGlobalPrefix('api/v1').
  /// - لو بتجرب على موبايل حقيقي على نفس الواي فاي (مش محاكي):
  ///   استخدم http://<IP بتاع الكمبيوتر>:3000/api/v1  مثلا http://192.168.1.5:3000/api/v1
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;

  // مفاتيح تخزين محلي (SharedPreferences)
  static const String accessTokenKey = 'mcsos_access_token';
  static const String refreshTokenKey = 'mcsos_refresh_token';
  static const String currentUserKey = 'mcsos_current_user';
}
