import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/application_entities.dart';
import '../../domain/usecases/create_application.dart';
import '../../domain/usecases/get_user_applications.dart';
import '../../domain/usecases/geocode_address.dart' as geocode_usecase;
import '../../domain/usecases/get_geolocation_address.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'application_event.dart';
import 'application_state.dart';
import '../../../auth/domain/usecases/update_profile.dart';
import '../../../auth/domain/entities/profile_entities.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final CreateApplication createApplication;
  final GetUserApplications getUserApplications;
  final geocode_usecase.GeocodeAddress geocodeAddress;
  final GetGeolocationAddress getGeolocationAddress;
  final AuthBloc authBloc;
  final UpdateProfile updateProfile;

  late final StreamSubscription<AuthState> _authStateSubscription;

  // Store pending geolocation data for profile update
  GeolocationResult? _pendingGeolocationResult;

  ApplicationBloc({
    required this.createApplication,
    required this.getUserApplications,
    required this.geocodeAddress,
    required this.getGeolocationAddress,
    required this.authBloc,
    required this.updateProfile,
  }) : super(const ApplicationFormState()) {
    print('🏗️ ApplicationBloc created');
    print('  - AuthBloc: ${authBloc.runtimeType}');
    print('  - AuthBloc state: ${authBloc.state.runtimeType}');
    _pendingGeolocationResult = null;

    on<CreateApplicationEvent>(_onCreateApplication);
    on<GetUserApplicationsEvent>(_onGetUserApplications);
    on<RefreshApplicationsEvent>(_onRefreshApplications);
    on<GeocodeAddressEvent>(_onGeocodeAddress);
    on<GetGeolocationEvent>(_onGetGeolocation);
    on<InitializeFormEvent>(_onInitializeForm);
    on<AuthStateChangedEvent>(_onAuthStateChangedEvent);
    on<ClearGeocodeResultsEvent>(_onClearGeocodeResults);
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateAddressQueryEvent>(_onUpdateAddressQuery);
    on<SelectGeocodeResultEvent>(_onSelectGeocodeResult);

    // Listen to AuthBloc state changes
    _authStateSubscription = authBloc.stream.listen((authState) {
      print('👂 AuthBloc state changed: ${authState.runtimeType}');
      if (authState is ProfileMeLoaded) {
        add(AuthStateChangedEvent(authState));
      }
    });
    print('👂 AuthBloc stream subscription set up');

    // Initialize with user's city if available
    _initializeWithUserCity();
  }

  void _initializeWithUserCity() {
    // Always dispatch InitializeFormEvent to ensure form gets initialized
    // whether profile is loaded or not
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

      // First emit the GeolocationSuccess state
      emit(GeolocationSuccess(result: result));

      // Check if user's city needs to be updated
      final geocodedCity = result.address.city;
      final authState = authBloc.state;

      print('🔍 Geolocation Profile Update Check:');
      print('  - Geocoded City: $geocodedCity');
      print('  - AuthBloc State: ${authState.runtimeType}');
      print('  - Geocoded city not empty: ${geocodedCity.isNotEmpty}');

      if (authState is ProfileMeLoaded) {
        final userCity = authState.profile.address.city;
        print('  - User City: $userCity');
        print('  - Cities different: ${userCity != geocodedCity}');

        if (userCity != geocodedCity && geocodedCity.isNotEmpty) {
          print('🚀 Starting geolocation profile update...');
          // Update user's profile with new city
          try {
            final updatedProfileData = ProfileData(
              phoneNumber: authState.profile.phoneNumber,
              name: authState.profile.name,
              surname: authState.profile.surname,
              position: authState.profile.position,
              addressQuery:
                  result.displayName, // Update with the geolocation address
            );

            print('📤 Sending geolocation profile update data:');
            print('  - Phone: ${updatedProfileData.phoneNumber}');
            print('  - Name: ${updatedProfileData.name}');
            print('  - Surname: ${updatedProfileData.surname}');
            print('  - Position: ${updatedProfileData.position}');
            print('  - Address Query: ${updatedProfileData.addressQuery}');

            final updatedResult = await updateProfile(updatedProfileData);
            print('✅ Geolocation profile update successful!');
            print('  - Updated profile ID: ${updatedResult.id}');
            print('  - Updated address: ${updatedResult.addressDisplay}');

            // Emit profile updated event to auth bloc
            authBloc.add(GetProfileMeEvent());
            print('🔄 Triggered profile refresh from geolocation');
          } catch (e) {
            print('❌ Geolocation profile update failed: $e');
            // If profile update fails, continue with form update but log error
          }
        } else {
          print(
            '⏭️ Skipping geolocation profile update - cities match or geocoded city empty',
          );
        }
      } else {
        print(
          '⚠️ Cannot update profile from geolocation - Auth state is not ProfileMeLoaded',
        );
        print('  - Current state: $authState');
        // Store the geolocation data for later profile update
        _pendingGeolocationResult = result;
        print('💾 Stored geolocation result for later profile update');
      }

      // Then update the form state with the geolocation data
      emit(
        currentState.copyWith(
          isLoading: false,
          addressQuery: result.displayName,
          latitude: double.parse(result.lat),
          longitude: double.parse(result.lon),
          selectedCity: geocodedCity, // Update the selected city in form state
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

    // Check if user's city needs to be updated
    final geocodedCity = event.address.address.city;
    final authState = authBloc.state;

    if (authState is ProfileMeLoaded) {
      final userCity = authState.profile.address.city;
      print('🔍 Profile Update Check:');
      print('  - Geocoded City: $geocodedCity');
      print('  - User City: $userCity');
      print('  - Cities different: ${userCity != geocodedCity}');
      print('  - Geocoded city not empty: ${geocodedCity.isNotEmpty}');

      if (userCity != geocodedCity && geocodedCity.isNotEmpty) {
        print('🚀 Starting profile update...');
        // Update user's profile with new city
        try {
          final updatedProfileData = ProfileData(
            phoneNumber: authState.profile.phoneNumber,
            name: authState.profile.name,
            surname: authState.profile.surname,
            position: authState.profile.position,
            addressQuery:
                event.address.displayName, // Update with the selected address
          );

          print('📤 Sending profile update data:');
          print('  - Phone: ${updatedProfileData.phoneNumber}');
          print('  - Name: ${updatedProfileData.name}');
          print('  - Surname: ${updatedProfileData.surname}');
          print('  - Position: ${updatedProfileData.position}');
          print('  - Address Query: ${updatedProfileData.addressQuery}');

          final result = await updateProfile(updatedProfileData);
          print('✅ Profile update successful!');
          print('  - Updated profile ID: ${result.id}');
          print('  - Updated address: ${result.addressDisplay}');

          // Emit profile updated event to auth bloc
          authBloc.add(GetProfileMeEvent());
          print('🔄 Triggered profile refresh');
        } catch (e) {
          print('❌ Profile update failed: $e');
          // If profile update fails, continue with form update but log error
        }
      } else {
        print(
          '⏭️ Skipping profile update - cities match or geocoded city empty',
        );
      }
    } else {
      print('⚠️ Cannot update profile - Auth state is not ProfileMeLoaded');
    }

    emit(
      currentState.copyWith(
        addressQuery: event.address.displayName,
        latitude: double.parse(event.address.lat),
        longitude: double.parse(event.address.lon),
        selectedCity: geocodedCity, // Update the selected city in form state
        selectedGeocodeResult: event.address,
        clearGeocodeResults: true,
      ),
    );
  }

  void _onInitializeForm(
    InitializeFormEvent event,
    Emitter<ApplicationState> emit,
  ) {
    print('📋 InitializeFormEvent received in ApplicationBloc');
    final authState = authBloc.state;
    print('🔍 ApplicationBloc AuthBloc state: ${authState.runtimeType}');

    if (authState is ProfileMeLoaded && state is ApplicationFormState) {
      final currentState = state as ApplicationFormState;
      final userCity = authState.profile.address.city;
      print('🏙️ User city from ApplicationBloc: $userCity');

      if (userCity.isNotEmpty) {
        print('📝 Emitting form state with user city: $userCity');
        emit(
          currentState.copyWith(
            addressQuery: currentState.addressQuery.isEmpty
                ? userCity
                : currentState.addressQuery,
            selectedCity: currentState.selectedCity?.isEmpty ?? true
                ? userCity
                : currentState.selectedCity,
          ),
        );
      } else {
        print('⚠️ User city is empty');
      }
    } else {
      print(
        '⚠️ Auth state is not ProfileMeLoaded or state is not ApplicationFormState',
      );
      print('  - Auth state: $authState');
      print('  - Application state: $state');
    }
  }

  void _onAuthStateChangedEvent(
    AuthStateChangedEvent event,
    Emitter<ApplicationState> emit,
  ) {
    print('📡 AuthStateChangedEvent received: ${event.authState.runtimeType}');

    if (event.authState is ProfileMeLoaded && state is ApplicationFormState) {
      final currentState = state as ApplicationFormState;
      final profileLoadedState = event.authState as ProfileMeLoaded;
      final userCity = profileLoadedState.profile.address.city;

      print('👤 Profile loaded in ApplicationBloc:');
      print('  - User City: $userCity');
      print('  - Current selected city: ${currentState.selectedCity}');

      // Check if we have pending geolocation data to update profile
      if (_pendingGeolocationResult != null) {
        final geocodedCity = _pendingGeolocationResult!.address.city;
        print('🔄 Processing pending geolocation update:');
        print('  - Pending geocoded city: $geocodedCity');
        print('  - User city: $userCity');
        print('  - Cities different: ${userCity != geocodedCity}');

        if (userCity != geocodedCity && geocodedCity.isNotEmpty) {
          print('🚀 Updating profile with pending geolocation data...');
          _updateProfileWithGeolocation(
            profileLoadedState,
            _pendingGeolocationResult!,
          );
        }
        _pendingGeolocationResult = null; // Clear pending data
      }

      // Only update if we don't already have a city set
      if (userCity.isNotEmpty && (currentState.selectedCity?.isEmpty ?? true)) {
        print('📝 Updating form with user city: $userCity');
        emit(
          currentState.copyWith(
            addressQuery: currentState.addressQuery.isEmpty
                ? userCity
                : currentState.addressQuery,
            selectedCity: userCity,
          ),
        );
      } else {
        print('⏭️ Skipping form update - city already set or user city empty');
      }
    } else {
      print(
        '⚠️ AuthStateChangedEvent ignored - not ProfileMeLoaded or wrong state type',
      );
    }
  }

  Future<void> _updateProfileWithGeolocation(
    ProfileMeLoaded profileState,
    GeolocationResult geolocationResult,
  ) async {
    try {
      final updatedProfileData = ProfileData(
        phoneNumber: profileState.profile.phoneNumber,
        name: profileState.profile.name,
        surname: profileState.profile.surname,
        position: profileState.profile.position,
        addressQuery: geolocationResult.displayName,
      );

      print('📤 Sending pending geolocation profile update data:');
      print('  - Phone: ${updatedProfileData.phoneNumber}');
      print('  - Address Query: ${updatedProfileData.addressQuery}');

      final updatedResult = await updateProfile(updatedProfileData);
      print('✅ Pending geolocation profile update successful!');
      print('  - Updated profile ID: ${updatedResult.id}');

      // Emit profile updated event to auth bloc
      authBloc.add(GetProfileMeEvent());
      print('🔄 Triggered profile refresh from pending geolocation');
    } catch (e) {
      print('❌ Pending geolocation profile update failed: $e');
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
