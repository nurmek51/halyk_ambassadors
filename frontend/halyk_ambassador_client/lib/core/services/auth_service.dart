import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/auth_entities.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accountIdKey = 'account_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _expiresAtKey = 'expires_at';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<void> saveAuthContext(AuthContext context) async {
    await _prefs.setString(_accessTokenKey, context.tokens.accessToken);
    await _prefs.setString(_refreshTokenKey, context.tokens.refreshToken);
    await _prefs.setString(_accountIdKey, context.accountId);
    await _prefs.setString(_phoneNumberKey, context.phoneNumber);

    // Calculate expiry if provided
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt(_expiresAtKey, now + (3600 * 1000)); // Default 1 hour
  }

  Future<AuthContext?> getAuthContext() async {
    final accessToken = _prefs.getString(_accessTokenKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    final accountId = _prefs.getString(_accountIdKey);
    final phoneNumber = _prefs.getString(_phoneNumberKey);

    if (accessToken != null &&
        refreshToken != null &&
        accountId != null &&
        phoneNumber != null) {
      return AuthContext(
        accountId: accountId,
        phoneNumber: phoneNumber,
        tokens: AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  Future<bool> isTokenExpired() async {
    final expiresAt = _prefs.getInt(_expiresAtKey);
    if (expiresAt == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiresAt;
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_accountIdKey);
    await _prefs.remove(_phoneNumberKey);
    await _prefs.remove(_expiresAtKey);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> updateTokens(AuthTokens tokens) async {
    await _prefs.setString(_accessTokenKey, tokens.accessToken);
    await _prefs.setString(_refreshTokenKey, tokens.refreshToken);

    // Update expiry time
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt(_expiresAtKey, now + (3600 * 1000)); // 1 hour
  }
}
