import '../entities/auth_entities.dart';
import '../entities/profile_entities.dart';

abstract class AuthRepository {
  Future<void> requestOtp(OtpRequest request);
  Future<AuthTokens> verifyOtp(OtpVerification verification);
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
  Future<AuthContext?> getAuthContext();
  Future<AuthTokens> refreshToken(String refreshToken);
  Future<AuthContext?> getStoredAuthContext();
  Future<bool> checkUserProfile(String accountId);

  // Profile methods
  Future<void> createProfile(ProfileData profileData);
  Future<List<City>> getCities();
  Future<UserProfile> getProfileMe();
}
