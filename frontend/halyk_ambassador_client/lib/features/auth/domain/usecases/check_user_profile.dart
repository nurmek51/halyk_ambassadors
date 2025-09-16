import '../../domain/entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class CheckUserProfile {
  final AuthRepository repository;

  CheckUserProfile(this.repository);

  Future<bool> call(String accountId) async {
    return await repository.checkUserProfile(accountId);
  }
}
