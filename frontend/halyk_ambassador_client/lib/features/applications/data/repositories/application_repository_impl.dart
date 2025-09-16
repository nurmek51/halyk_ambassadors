import '../../domain/entities/application_entities.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';
import '../models/application_models.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Application> createApplication(
    CreateApplicationRequest request,
  ) async {
    final model = CreateApplicationRequestModel.fromEntity(request);
    return await remoteDataSource.createApplication(model);
  }

  @override
  Future<GeocodeResult> geocodeAddress(String query, int limit) async {
    return await remoteDataSource.geocodeAddress(query, limit);
  }

  @override
  Future<List<Application>> getUserApplications() async {
    return await remoteDataSource.getUserApplications();
  }

  @override
  Future<GeolocationResult> getGeolocationAddress(
    GeolocationRequest request,
  ) async {
    final model = GeolocationRequestModel.fromEntity(request);
    return await remoteDataSource.getGeolocationAddress(model);
  }
}
