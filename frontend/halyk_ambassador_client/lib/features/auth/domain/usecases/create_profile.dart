import '../entities/profile_entities.dart';
import '../repositories/auth_repository.dart';

class CreateProfile {
  final AuthRepository repository;

  CreateProfile(this.repository);

  Future<void> call(ProfileData profileData) async {
    await repository.createProfile(profileData);
  }
}

class GetCities {
  final AuthRepository repository;

  GetCities(this.repository);

  Future<List<City>> call() async {
    return await repository.getCities();
  }
}
