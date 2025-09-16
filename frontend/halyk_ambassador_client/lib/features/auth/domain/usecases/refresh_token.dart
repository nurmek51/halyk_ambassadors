import '../../domain/entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class RefreshToken {
  final AuthRepository repository;

  RefreshToken(this.repository);

  Future<AuthTokens> call(String refreshToken) async {
    return await repository.refreshToken(refreshToken);
  }
}

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<AuthContext?> call() async {
    return await repository.getStoredAuthContext();
  }
}
