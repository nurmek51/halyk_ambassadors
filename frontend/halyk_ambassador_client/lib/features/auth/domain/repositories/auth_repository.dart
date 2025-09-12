import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<void> requestOtp(OtpRequest request);
  Future<AuthTokens> verifyOtp(OtpVerification verification);
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
}
