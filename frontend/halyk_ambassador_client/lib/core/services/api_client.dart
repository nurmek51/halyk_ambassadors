import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiClient {
  late final Dio _dio;
  final AuthService _authService;
  final String baseUrl;

  ApiClient({required this.baseUrl, required AuthService authService})
    : _authService = authService {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';

    // Request interceptor - add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_requiresAuth(options.path)) {
            final token = await _authService.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // TODO: Implement refresh token logic
            await _authService.clearAuth();
          }
          handler.next(error);
        },
      ),
    );
  }

  bool _requiresAuth(String path) {
    return path.contains('/api/accounts/') ||
        path.contains('/api/users/') ||
        (path.startsWith('/api/') && !path.contains('/auth/'));
  }

  Dio get dio => _dio;

  // Convenience methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
