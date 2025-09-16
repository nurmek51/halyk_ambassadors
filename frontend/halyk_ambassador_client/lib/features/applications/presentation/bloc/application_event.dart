import 'package:equatable/equatable.dart';
import '../../domain/entities/application_entities.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class CreateApplicationEvent extends ApplicationEvent {
  final String description;
  final List<String> imageUrls;
  final String addressQuery;
  final double latitude;
  final double longitude;

  const CreateApplicationEvent({
    required this.description,
    required this.imageUrls,
    required this.addressQuery,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    description,
    imageUrls,
    addressQuery,
    latitude,
    longitude,
  ];
}

class GeocodeAddressEvent extends ApplicationEvent {
  final String query;
  final int limit;

  const GeocodeAddressEvent({required this.query, this.limit = 1});

  @override
  List<Object?> get props => [query, limit];
}

class GetGeolocationEvent extends ApplicationEvent {
  final double latitude;
  final double longitude;

  const GetGeolocationEvent({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class InitializeFormEvent extends ApplicationEvent {}

class AuthStateChangedEvent extends ApplicationEvent {
  final AuthState authState;

  const AuthStateChangedEvent(this.authState);

  @override
  List<Object?> get props => [authState];
}

class ClearGeocodeResultsEvent extends ApplicationEvent {}

class AddImageEvent extends ApplicationEvent {
  final String imagePath;

  const AddImageEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class RemoveImageEvent extends ApplicationEvent {
  final int index;

  const RemoveImageEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class UpdateDescriptionEvent extends ApplicationEvent {
  final String description;

  const UpdateDescriptionEvent({required this.description});

  @override
  List<Object?> get props => [description];
}

class UpdateAddressQueryEvent extends ApplicationEvent {
  final String addressQuery;

  const UpdateAddressQueryEvent({required this.addressQuery});

  @override
  List<Object?> get props => [addressQuery];
}

class SelectGeocodeResultEvent extends ApplicationEvent {
  final GeocodeAddress address;

  const SelectGeocodeResultEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class GetUserApplicationsEvent extends ApplicationEvent {}

class RefreshApplicationsEvent extends ApplicationEvent {}
