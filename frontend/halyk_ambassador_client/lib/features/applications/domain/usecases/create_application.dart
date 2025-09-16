import '../entities/application_entities.dart';
import '../repositories/application_repository.dart';

class CreateApplication {
  final ApplicationRepository repository;

  CreateApplication(this.repository);

  Future<Application> call(CreateApplicationRequest request) async {
    return await repository.createApplication(request);
  }
}
