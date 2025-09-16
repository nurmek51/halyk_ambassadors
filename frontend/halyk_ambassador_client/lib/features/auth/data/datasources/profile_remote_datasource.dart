import 'package:dio/dio.dart';
import '../models/profile_models.dart';

abstract class ProfileRemoteDataSource {
  Future<void> createProfile(ProfileDataModel profileData);
  Future<List<CityModel>> getCities();
  Future<ProfileDataModel> getUserProfile(String accountId);
  Future<UserProfileModel> getProfileMe();
  Future<UserProfileModel> updateProfile(ProfileDataModel profileData);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> createProfile(ProfileDataModel profileData) async {
    try {
      await dio.post('/api/accounts/profile/', data: profileData.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CityModel>> getCities() async {
    // For now return mock data based on Figma design
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay

    return [
      const CityModel(id: '1', name: 'Астана'),
      const CityModel(id: '2', name: 'Алматы'),
      const CityModel(id: '3', name: 'Абай'),
      const CityModel(id: '4', name: 'Акколь'),
      const CityModel(id: '5', name: 'Аксай'),
      const CityModel(id: '6', name: 'Аксу'),
      const CityModel(id: '7', name: 'Актау'),
      const CityModel(id: '8', name: 'Актобе'),
      const CityModel(id: '9', name: 'Алатау'),
      const CityModel(id: '10', name: 'Алга'),
      const CityModel(id: '11', name: 'Алтай'),
      const CityModel(id: '12', name: 'Арал'),
      const CityModel(id: '13', name: 'Аркалык'),
    ];
  }

  @override
  Future<ProfileDataModel> getUserProfile(String accountId) async {
    try {
      final response = await dio.get('/api/accounts/profile/$accountId');
      return ProfileDataModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserProfileModel> getProfileMe() async {
    print('🌐 Making GET request to /api/accounts/profile/me/');
    try {
      final response = await dio.get('/api/accounts/profile/me/');
      print('✅ GET profile request successful!');
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      final result = UserProfileModel.fromJson(response.data);
      print('🔄 Parsed profile response successfully');
      print('  - Profile ID: ${result.id}');
      print('  - Full Name: ${result.fullName}');
      print('  - Address Display: ${result.addressDisplay}');
      print('  - City: ${result.address.city}');

      return result;
    } on DioException catch (e) {
      print('❌ GET profile request failed!');
      print('  - Error type: ${e.type}');
      print('  - Status code: ${e.response?.statusCode}');
      print('  - Error message: ${e.message}');
      print('  - Response data: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile(ProfileDataModel profileData) async {
    print('🌐 Making PUT request to /api/accounts/profile/me/');
    print('📤 Request data: ${profileData.toJson()}');

    // Add validation to ensure address_query is not empty
    if (profileData.addressQuery.isEmpty) {
      print('❌ Address query is empty - aborting update');
      throw Exception('Address query cannot be empty');
    }

    try {
      final response = await dio.put(
        '/api/accounts/profile/me/',
        data: profileData.toJson(),
      );

      print('✅ PUT request successful!');
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      final result = UserProfileModel.fromJson(response.data);
      print('🔄 Parsed response successfully');
      print('  - Profile ID: ${result.id}');
      print('  - Address Display: ${result.addressDisplay}');
      print('  - City: ${result.address.city}');

      return result;
    } on DioException catch (e) {
      print('❌ PUT request failed!');
      print('  - Error type: ${e.type}');
      print('  - Status code: ${e.response?.statusCode}');
      print('  - Error message: ${e.message}');
      print('  - Response data: ${e.response?.data}');
      print('  - Request data that was sent: ${profileData.toJson()}');
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception('Неверный формат данных');
      case 401:
        return Exception('Неавторизован');
      case 404:
        return Exception('Профиль не найден');
      case 422:
        return Exception('Данные не прошли валидацию');
      case 500:
        return Exception('Ошибка сервера');
      default:
        return Exception('Ошибка сети');
    }
  }
}
