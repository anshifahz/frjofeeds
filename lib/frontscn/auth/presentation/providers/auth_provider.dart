import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frijofeeds/core/constants/api_endpoints.dart';
import 'package:frijofeeds/frontscn/auth/data/models/token_model.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio;
  String? _token;
  bool _isLoading = false;

  AuthProvider(this._dio);

  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> verifyOtp(String countryCode, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Attempting OTP Verification...');

      final formData = FormData.fromMap({
        'country_code': countryCode,
        'phone': phone,
      });

      final response = await _dio.post(
        ApiEndpoints.otpVerified,
        data: formData,
        options: Options(
          validateStatus: (status) =>
              true, // Allow us to see 400/404/405 bodies
        ),
      );

      debugPrint('OTP Response Status: ${response.statusCode}');
      debugPrint('OTP Response Data: ${response.data}');

      // Some APIs return 200 with status description, others might be specific.
      // Checking for 'status': true as per user's log response.
      final isSuccess =
          (response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 202) ||
          (response.data is Map && response.data['status'] == true);

      if (isSuccess) {
        debugPrint('Auth Success Condition Met!');
        final authResponse = AuthResponse.fromJson(response.data);
        _token = authResponse.accessToken;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint(
          'Auth Condition Failed: Status=${response.statusCode}, Data=${response.data}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Auth Dio Error: ${e.response?.data}');
      debugPrint('Auth Status Code: ${e.response?.statusCode}');
    } catch (e) {
      debugPrint('Auth Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _token = null;
    notifyListeners();
  }
}
