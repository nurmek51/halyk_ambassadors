import 'package:equatable/equatable.dart';
import '../../domain/entities/application_entities.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationCreated extends ApplicationState {
  final Application application;

  const ApplicationCreated({required this.application});

  @override
  List<Object?> get props => [application];
}

class ApplicationError extends ApplicationState {
  final String message;

  const ApplicationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeocodeLoading extends ApplicationState {}

class GeocodeSuccess extends ApplicationState {
  final List<GeocodeAddress> results;

  const GeocodeSuccess({required this.results});

  @override
  List<Object?> get props => [results];
}

class GeocodeError extends ApplicationState {
  final String message;

  const GeocodeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeolocationLoading extends ApplicationState {}

class GeolocationSuccess extends ApplicationState {
  final GeolocationResult result;

  const GeolocationSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class GeolocationError extends ApplicationState {
  final String message;

  const GeolocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ApplicationsHistoryLoading extends ApplicationState {}

class ApplicationsHistoryLoaded extends ApplicationState {
  final List<Application> applications;

  const ApplicationsHistoryLoaded({required this.applications});

  @override
  List<Object?> get props => [applications];
}

class ApplicationsHistoryError extends ApplicationState {
  final String message;

  const ApplicationsHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ApplicationFormState extends ApplicationState {
  final String description;
  final List<String> imageUrls;
  final String addressQuery;
  final double? latitude;
  final double? longitude;
  final String? selectedCity;
  final List<GeocodeAddress> geocodeResults;
  final GeocodeAddress? selectedGeocodeResult;
  final bool isLoading;
  final String? error;

  const ApplicationFormState({
    this.description = '',
    this.imageUrls = const [],
    this.addressQuery = '',
    this.latitude,
    this.longitude,
    this.selectedCity,
    this.geocodeResults = const [],
    this.selectedGeocodeResult,
    this.isLoading = false,
    this.error,
  });

  ApplicationFormState copyWith({
    String? description,
    List<String>? imageUrls,
    String? addressQuery,
    double? latitude,
    double? longitude,
    String? selectedCity,
    List<GeocodeAddress>? geocodeResults,
    GeocodeAddress? selectedGeocodeResult,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearLatLng = false,
    bool clearGeocodeResults = false,
    bool clearSelectedGeocodeResult = false,
  }) {
    return ApplicationFormState(
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      addressQuery: addressQuery ?? this.addressQuery,
      latitude: clearLatLng ? null : (latitude ?? this.latitude),
      longitude: clearLatLng ? null : (longitude ?? this.longitude),
      selectedCity: selectedCity ?? this.selectedCity,
      geocodeResults: clearGeocodeResults
          ? []
          : (geocodeResults ?? this.geocodeResults),
      selectedGeocodeResult: clearSelectedGeocodeResult
          ? null
          : (selectedGeocodeResult ?? this.selectedGeocodeResult),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isValid {
    return description.trim().isNotEmpty &&
        addressQuery.trim().isNotEmpty &&
        latitude != null &&
        longitude != null;
  }

  @override
  List<Object?> get props => [
    description,
    imageUrls,
    addressQuery,
    latitude,
    longitude,
    selectedCity,
    geocodeResults,
    selectedGeocodeResult,
    isLoading,
    error,
  ];
}
