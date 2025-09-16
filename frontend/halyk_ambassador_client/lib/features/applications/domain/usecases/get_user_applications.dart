import '../entities/application_entities.dart';
import '../repositories/application_repository.dart';

class GetUserApplications {
  final ApplicationRepository repository;

  GetUserApplications(this.repository);

  Future<List<Application>> call() async {
    return await repository.getUserApplications();
  }
}
