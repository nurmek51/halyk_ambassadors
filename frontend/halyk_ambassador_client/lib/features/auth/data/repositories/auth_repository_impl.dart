import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> requestOtp(OtpRequest request) async {
    final model = OtpRequestModel.fromEntity(request);
    await remoteDataSource.requestOtp(model);
  }

  @override
  Future<AuthTokens> verifyOtp(OtpVerification verification) async {
    final model = OtpVerificationModel.fromEntity(verification);
    return await remoteDataSource.verifyOtp(model);
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await sharedPreferences.setString(_accessTokenKey, tokens.accessToken);
    await sharedPreferences.setString(_refreshTokenKey, tokens.refreshToken);
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final accessToken = sharedPreferences.getString(_accessTokenKey);
    final refreshToken = sharedPreferences.getString(_refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    await sharedPreferences.remove(_accessTokenKey);
    await sharedPreferences.remove(_refreshTokenKey);
  }
}
