import '../entities/profile_entities.dart';
import '../repositories/auth_repository.dart';

class GetProfileMeUseCase {
  final AuthRepository repository;

  GetProfileMeUseCase(this.repository);

  Future<UserProfile> call() => repository.getProfileMe();
}
