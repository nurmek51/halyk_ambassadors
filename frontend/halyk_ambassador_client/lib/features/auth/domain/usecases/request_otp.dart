import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class RequestOtp {
  final AuthRepository repository;

  RequestOtp(this.repository);

  Future<void> call(OtpRequest request) async {
    return await repository.requestOtp(request);
  }
}
