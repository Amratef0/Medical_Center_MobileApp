import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

/// نفس مفتاح navigator بتاع الابليكيشن كله، بنستخدمه عشان نقدر نرجع
/// المستخدم لشاشة اللوجين من أي مكان (مثلا لما التوكن ينتهي).
final navigatorKey = GlobalKey<NavigatorState>();

/// الكلاس ده مسؤول عن كل الاتصال بالباك اند.
/// بيعمل نفس اللي بيعمله api.js في الفرونت إند (axios interceptors):
/// 1. يحط الـ access token في كل request.
/// 2. لو رجع 401 (التوكن خلص) يحاول يعمل refresh تلقائي، ولو فشل يرجع للوجين.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_authInterceptor());
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Dio get dio => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');

        if (isUnauthorized && !isRefreshCall) {
          try {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken == null) throw Exception('لا يوجد refresh token');

            // نعمل نداء منفصل للـ refresh بنفس الطريقة اللي الباك اند مطلوبها
            // (JwtRefreshGuard بياخد الـ refresh token في هيدر Authorization).
            final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
            );

            final newAccessToken = refreshResponse.data['access_token'] as String;
            final newRefreshToken =
                (refreshResponse.data['refresh_token'] as String?) ?? refreshToken;

            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // نعيد نفس الريكوست الأصلي بالتوكن الجديد
            final originalRequest = error.requestOptions;
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(originalRequest);
            return handler.resolve(retryResponse);
          } catch (_) {
            await _tokenStorage.clearAll();
            // نرجع اليوزر لشاشة تسجيل الدخول
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }

        handler.next(error);
      },
    );
  }
}
