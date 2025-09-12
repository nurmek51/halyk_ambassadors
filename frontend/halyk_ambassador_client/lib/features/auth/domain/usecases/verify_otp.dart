import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<AuthTokens> call(OtpVerification verification) async {
    final tokens = await repository.verifyOtp(verification);
    await repository.saveTokens(tokens);
    return tokens;
  }
}
