import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;
  final AuthService authService;
  final Dio dio;

  AuthInterceptor({
    required this.sharedPreferences,
    required this.authService,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip adding authorization header for auth endpoints (login, refresh-token, etc.)
    if (!options.path.startsWith('/auth/')) {
      // Add authorization header for authenticated endpoints
      if (_requiresAuth(options.path)) {
        final accessToken = sharedPreferences.getString('access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
    }

    // Always add Content-Type for JSON requests
    options.headers['Content-Type'] = 'application/json';

    handler.next(options);
  }

  bool _requiresAuth(String path) {
    // Auth endpoints don't require authorization headers
    if (path.startsWith('/auth/')) {
      return false;
    }

    // Protected API endpoints require authentication
    return path.startsWith('/api/');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Skip token refresh for auth endpoints (login, refresh-token, etc.)
    if (err.requestOptions.path.startsWith('/auth/')) {
      handler.next(err);
      return;
    }

    // Handle token refresh on 401 errors for protected endpoints
    if (err.response?.statusCode == 401 &&
        _requiresAuth(err.requestOptions.path)) {
      try {
        final refreshToken = await authService.getRefreshToken();
        if (refreshToken != null) {
          // Try to refresh the token
          final response = await dio.post(
            '/auth/refresh-token',
            data: {'refresh_token': refreshToken},
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                // Explicitly remove any authorization header
                'Authorization': null,
              },
              receiveTimeout: const Duration(seconds: 60), // Increased timeout
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            // Save new tokens
            await sharedPreferences.setString('access_token', newAccessToken);
            await sharedPreferences.setString('refresh_token', newRefreshToken);

            // Retry the original request with new token
            final originalRequest = err.requestOptions;
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(originalRequest);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Token refresh failed, clear auth and redirect to login
        await authService.clearAuth();
      }
    }

    handler.next(err);
  }
}
