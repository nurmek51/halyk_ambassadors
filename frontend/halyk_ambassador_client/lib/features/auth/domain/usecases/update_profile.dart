import '../entities/profile_entities.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<UserProfile> call(ProfileData profileData) async {
    return await repository.updateProfile(profileData);
  }
}
