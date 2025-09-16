import '../entities/application_entities.dart';
import '../repositories/application_repository.dart';

class GeocodeAddress {
  final ApplicationRepository repository;

  GeocodeAddress(this.repository);

  Future<GeocodeResult> call(String query, int limit) async {
    return await repository.geocodeAddress(query, limit);
  }
}
