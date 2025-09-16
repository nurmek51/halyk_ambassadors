import 'package:dio/dio.dart';
import '../models/application_models.dart';

abstract class ApplicationRemoteDataSource {
  Future<ApplicationModel> createApplication(
    CreateApplicationRequestModel request,
  );

  Future<List<ApplicationModel>> getUserApplications();

  Future<GeocodeResultModel> geocodeAddress(String query, int limit);

  Future<GeolocationResultModel> getGeolocationAddress(
    GeolocationRequestModel request,
  );
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final Dio dio;

  ApplicationRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApplicationModel> createApplication(
    CreateApplicationRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/api/applications/',
        data: request.toJson(),
      );

      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<GeocodeResultModel> geocodeAddress(String query, int limit) async {
    try {
      final response = await dio.post(
        '/api/geo/geocode',
        data: {'query': query, 'limit': limit},
      );

      return GeocodeResultModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<ApplicationModel>> getUserApplications() async {
    try {
      final response = await dio.get('/api/applications/me');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ApplicationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<GeolocationResultModel> getGeolocationAddress(
    GeolocationRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/api/geo/geolocation-address',
        data: request.toJson(),
      );

      return GeolocationResultModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          return Exception('Invalid request data');
        } else if (statusCode == 401) {
          return Exception('Authentication required');
        } else if (statusCode == 404) {
          return Exception('Resource not found');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('Request failed with status: $statusCode');
      case DioExceptionType.unknown:
        return Exception('Network error. Please check your connection.');
      default:
        return Exception('Something went wrong. Please try again.');
    }
  }
}
