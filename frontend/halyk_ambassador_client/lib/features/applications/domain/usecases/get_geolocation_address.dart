import '../entities/application_entities.dart';
import '../repositories/application_repository.dart';

class GetGeolocationAddress {
  final ApplicationRepository repository;

  GetGeolocationAddress(this.repository);

  Future<GeolocationResult> call(GeolocationRequest request) async {
    return await repository.getGeolocationAddress(request);
  }
}
