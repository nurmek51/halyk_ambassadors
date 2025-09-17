import 'package:dio/dio.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp(OtpRequestModel request);
  Future<AuthTokensModel> verifyOtp(OtpVerificationModel verification);
  Future<AuthTokensModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> requestOtp(OtpRequestModel request) async {
    try {
      await dio.post('/auth/request-otp', data: request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthTokensModel> verifyOtp(OtpVerificationModel verification) async {
    try {
      final response = await dio.post(
        '/auth/verify-otp',
        data: verification.toJson(),
      );

      return AuthTokensModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String token) async {
    try {
      print('🔄 Making refresh token request...');
      // Use longer timeout for refresh token requests and ensure no auth header
      final response = await dio.post(
        '/auth/refresh-token',
        data: {'refresh_token': token},
        options: Options(
          receiveTimeout: const Duration(seconds: 60), // Increased timeout
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            // Explicitly remove any authorization header for refresh requests
            'Authorization': null,
          },
        ),
      );

      print('✅ Refresh token response received');
      return AuthTokensModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Refresh token request failed: ${e.message}');
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception('Неверный формат данных');
      case 401:
        return Exception('Неверный код');
      case 429:
        return Exception('Слишком много попыток. Попробуйте позже');
      case 500:
        return Exception('Ошибка сервера');
      default:
        return Exception('Ошибка сети');
    }
  }
}
