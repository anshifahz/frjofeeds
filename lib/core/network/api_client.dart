import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  ApiClient() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip Authorization header for login/OTP and category_list endpoints
          if (options.path.contains(ApiEndpoints.otpVerified) ||
              options.path.contains(ApiEndpoints.categoryList)) {
            return handler.next(options);
          }

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          debugPrint('🔐 API Request to: ${options.path}');
          debugPrint(
            '🔑 Token from storage: ${token != null ? "Found (${token.substring(0, 20)}...)" : "NOT FOUND"}',
          );

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('✅ Authorization header set');
          } else {
            debugPrint('❌ No token available - request will fail');
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          // Handle global errors here
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
