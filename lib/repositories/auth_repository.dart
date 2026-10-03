import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

/// كل اللي يخص تسجيل الدخول والخروج، نفس /auth بتاعة الباك اند.
class AuthRepository {
  final _dio = ApiClient().dio;
  final _tokenStorage = TokenStorage();

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _tokenStorage.saveCurrentUser(userJson);

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // حتى لو الـ request فشل (مثلا مفيش نت) لسه هنمسح البيانات محليا
    }
    await _tokenStorage.clearAll();
  }

  /// بيتشاف لو فيه توكن محفوظ من قبل عشان نعرف نروح على الداشبورد ولا اللوجين.
  Future<UserModel?> getSavedUser() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;
    final userJson = await _tokenStorage.getCurrentUser();
    if (userJson == null) return null;
    return UserModel.fromJson(userJson);
  }
}
