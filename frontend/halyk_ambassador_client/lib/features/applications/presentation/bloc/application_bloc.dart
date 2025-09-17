import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/application_entities.dart';
import '../../domain/usecases/create_application.dart';
import '../../domain/usecases/get_user_applications.dart';
import '../../domain/usecases/geocode_address.dart' as geocode_usecase;
import '../../domain/usecases/get_geolocation_address.dart';
import 'application_event.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final CreateApplication createApplication;
  final GetUserApplications getUserApplications;
  final geocode_usecase.GeocodeAddress geocodeAddress;
  final GetGeolocationAddress getGeolocationAddress;

  ApplicationBloc({
    required this.createApplication,
    required this.getUserApplications,
    required this.geocodeAddress,
    required this.getGeolocationAddress,
  }) : super(const ApplicationFormState()) {
    on<CreateApplicationEvent>(_onCreateApplication);
    on<GetUserApplicationsEvent>(_onGetUserApplications);
    on<RefreshApplicationsEvent>(_onRefreshApplications);
    on<GeocodeAddressEvent>(_onGeocodeAddress);
    on<GetGeolocationEvent>(_onGetGeolocation);
    on<InitializeFormEvent>(_onInitializeForm);
    on<ClearGeocodeResultsEvent>(_onClearGeocodeResults);
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateAddressQueryEvent>(_onUpdateAddressQuery);
    on<SelectGeocodeResultEvent>(_onSelectGeocodeResult);

    // Initialize form via event only.
    add(InitializeFormEvent());
  }

  Future<void> _onCreateApplication(
    CreateApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(
      (state as ApplicationFormState).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final request = CreateApplicationRequest(
        description: event.description,
        imageUrls: event.imageUrls,
        addressQuery: event.addressQuery,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      final application = await createApplication(request);

      emit(ApplicationCreated(application: application));
    } catch (e) {
      emit(
        (state as ApplicationFormState).copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onGetUserApplications(
    GetUserApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationsHistoryLoading());

    try {
      final applications = await getUserApplications();
      emit(ApplicationsHistoryLoaded(applications: applications));
    } catch (e) {
      emit(ApplicationsHistoryError(message: e.toString()));
    }
  }

  Future<void> _onRefreshApplications(
    RefreshApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      final applications = await getUserApplications();
      emit(ApplicationsHistoryLoaded(applications: applications));
    } catch (e) {
      emit(ApplicationsHistoryError(message: e.toString()));
    }
  }

  Future<void> _onGeocodeAddress(
    GeocodeAddressEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final currentState = state as ApplicationFormState;
    emit(currentState.copyWith(isLoading: true, clearError: true));

    try {
      final result = await geocodeAddress(event.query, event.limit);

      emit(
        currentState.copyWith(isLoading: false, geocodeResults: result.results),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onGetGeolocation(
    GetGeolocationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final currentState = state as ApplicationFormState;
    emit(currentState.copyWith(isLoading: true, clearError: true));

    try {
      final request = GeolocationRequest(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      final result = await getGeolocationAddress(request);

      // Emit the geolocation result and update the form state
      emit(GeolocationSuccess(result: result));
      emit(
        currentState.copyWith(
          isLoading: false,
          addressQuery: result.displayName,
          latitude: double.parse(result.lat),
          longitude: double.parse(result.lon),
          selectedCity: result.address.city,
          clearGeocodeResults: true,
        ),
      );
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      emit(currentState.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onClearGeocodeResults(
    ClearGeocodeResultsEvent event,
    Emitter<ApplicationState> emit,
  ) {
    final currentState = state as ApplicationFormState;
    emit(currentState.copyWith(clearGeocodeResults: true));
  }

  void _onAddImage(AddImageEvent event, Emitter<ApplicationState> emit) {
    final currentState = state as ApplicationFormState;
    final updatedImages = List<String>.from(currentState.imageUrls)
      ..add(event.imagePath);

    emit(currentState.copyWith(imageUrls: updatedImages));
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter<ApplicationState> emit) {
    final currentState = state as ApplicationFormState;
    final updatedImages = List<String>.from(currentState.imageUrls)
      ..removeAt(event.index);

    emit(currentState.copyWith(imageUrls: updatedImages));
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<ApplicationState> emit,
  ) {
    final currentState = state as ApplicationFormState;
    emit(currentState.copyWith(description: event.description));
  }

  void _onUpdateAddressQuery(
    UpdateAddressQueryEvent event,
    Emitter<ApplicationState> emit,
  ) {
    final currentState = state as ApplicationFormState;
    emit(
      currentState.copyWith(
        addressQuery: event.addressQuery,
        clearLatLng: true,
        clearGeocodeResults: true,
      ),
    );
  }

  void _onSelectGeocodeResult(
    SelectGeocodeResultEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final currentState = state as ApplicationFormState;

    // Update the form with the selected geocode result
    emit(
      currentState.copyWith(
        addressQuery: event.address.displayName,
        latitude: double.parse(event.address.lat),
        longitude: double.parse(event.address.lon),
        selectedCity: event.address.address.city,
        selectedGeocodeResult: event.address,
        clearGeocodeResults: true,
      ),
    );
  }

  void _onInitializeForm(
    InitializeFormEvent event,
    Emitter<ApplicationState> emit,
  ) {
    // Initialize form — no profile-based changes here. The form state is left as default.
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
