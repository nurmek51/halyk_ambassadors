import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/auth_models.dart';
import '../models/profile_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ProfileRemoteDataSource profileRemoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.profileRemoteDataSource,
    required this.sharedPreferences,
  });

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accountIdKey = 'account_id';
  static const String _phoneNumberKey = 'phone_number';

  @override
  Future<void> requestOtp(OtpRequest request) async {
    final model = OtpRequestModel.fromEntity(request);
    await remoteDataSource.requestOtp(model);
  }

  @override
  Future<AuthTokens> verifyOtp(OtpVerification verification) async {
    final model = OtpVerificationModel.fromEntity(verification);
    final tokensModel = await remoteDataSource.verifyOtp(model);

    // Store tokens and context
    await saveTokens(tokensModel);
    if (tokensModel.accountId != null) {
      await sharedPreferences.setString(_accountIdKey, tokensModel.accountId!);
    }
    if (tokensModel.phoneNumber != null) {
      await sharedPreferences.setString(
        _phoneNumberKey,
        tokensModel.phoneNumber!,
      );
    }

    return tokensModel;
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
    await sharedPreferences.remove(_accountIdKey);
    await sharedPreferences.remove(_phoneNumberKey);
  }

  @override
  Future<AuthContext?> getAuthContext() async {
    final tokens = await getTokens();
    final accountId = sharedPreferences.getString(_accountIdKey);
    final phoneNumber = sharedPreferences.getString(_phoneNumberKey);

    if (tokens != null && accountId != null && phoneNumber != null) {
      return AuthContext(
        accountId: accountId,
        phoneNumber: phoneNumber,
        tokens: tokens,
      );
    }
    return null;
  }

  @override
  Future<void> createProfile(ProfileData profileData) async {
    final model = ProfileDataModel.fromEntity(profileData);
    await profileRemoteDataSource.createProfile(model);
  }

  @override
  Future<List<City>> getCities() async {
    final models = await profileRemoteDataSource.getCities();
    return models.map((model) => City(id: model.id, name: model.name)).toList();
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final newTokens = await remoteDataSource.refreshToken(refreshToken);
    await saveTokens(newTokens);
    return newTokens;
  }

  @override
  Future<AuthContext?> getStoredAuthContext() async {
    return await getAuthContext();
  }

  @override
  Future<bool> checkUserProfile(String accountId) async {
    try {
      // Try to get user profile to check if it exists
      await profileRemoteDataSource.getUserProfile(accountId);
      return true;
    } catch (e) {
      // If profile doesn't exist or there's an error, return false
      return false;
    }
  }

  @override
  Future<UserProfile> getProfileMe() async {
    final model = await profileRemoteDataSource.getProfileMe();
    return model;
  }
}
