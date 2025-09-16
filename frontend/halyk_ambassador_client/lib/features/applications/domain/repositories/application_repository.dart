import '../entities/application_entities.dart';

abstract class ApplicationRepository {
  Future<Application> createApplication(CreateApplicationRequest request);

  Future<List<Application>> getUserApplications();

  Future<GeocodeResult> geocodeAddress(String query, int limit);

  Future<GeolocationResult> getGeolocationAddress(GeolocationRequest request);
}
