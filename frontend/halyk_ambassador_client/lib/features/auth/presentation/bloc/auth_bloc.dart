import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/create_profile.dart';
import '../../domain/usecases/refresh_token.dart';
import '../../domain/usecases/check_user_profile.dart';
import '../../domain/usecases/get_profile_me.dart';
import '../../domain/usecases/update_profile.dart';
import '../../data/models/auth_models.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final CreateProfile createProfile;
  final GetCities getCities;
  final RefreshToken refreshToken;
  final CheckAuthStatus checkAuthStatus;
  final CheckUserProfile checkUserProfile;
  final GetProfileMeUseCase getProfileMe;
  final UpdateProfile updateProfile;

  bool _isRefreshingToken = false;

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.createProfile,
    required this.getCities,
    required this.refreshToken,
    required this.checkAuthStatus,
    required this.checkUserProfile,
    required this.getProfileMe,
    required this.updateProfile,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<CreateProfileEvent>(_onCreateProfile);
    on<LoadCitiesEvent>(_onLoadCities);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<LogoutEvent>(_onLogout);
    on<CheckUserProfileEvent>(_onCheckUserProfile);
    on<GetProfileMeEvent>(_onGetProfileMe);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await requestOtp(OtpRequest(phoneNumber: event.phoneNumber));
      emit(OtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final tokens = await verifyOtp(
        OtpVerification(phoneNumber: event.phoneNumber, otpCode: event.otpCode),
      );

      // Create auth context and check profile immediately
      String accountId = 'temp_account_id'; // fallback
      if (tokens is AuthTokensModel && tokens.accountId != null) {
        accountId = tokens.accountId!;
      }

      final authContext = AuthContext(
        accountId: accountId,
        phoneNumber: event.phoneNumber,
        tokens: tokens,
      );

      // Check if user profile exists and load data immediately
      final profileExists = await checkUserProfile(accountId);
      if (profileExists) {
        // Load profile data immediately after authentication
        emit(ProfileMeLoading());
        try {
          final profile = await getProfileMe();
          emit(ProfileMeLoaded(profile));
        } catch (e) {
          // If profile loading fails, still show user as authenticated
          emit(UserProfileExists(authContext));
        }
      } else {
        emit(UserProfileNotFound(authContext));
      }
    } catch (e) {
      emit(OtpError(message: e.toString(), phoneNumber: event.phoneNumber));
    }
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await requestOtp(OtpRequest(phoneNumber: event.phoneNumber));
      emit(OtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateProfile(
    CreateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await createProfile(event.profileData);
      // After profile creation, get the current auth context and load profile data
      final authContext = await checkAuthStatus();
      if (authContext != null) {
        // Load profile data immediately after creation
        emit(ProfileMeLoading());
        try {
          final profile = await getProfileMe();
          emit(ProfileMeLoaded(profile));
        } catch (e) {
          // If profile loading fails, still show user as authenticated
          emit(UserProfileExists(authContext));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final cities = await getCities();
      emit(CitiesLoaded(cities));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authContext = await checkAuthStatus();
      if (authContext != null) {
        // User has valid tokens, check if they have a profile
        final profileExists = await checkUserProfile(authContext.accountId);
        if (profileExists) {
          // Load profile data immediately after authentication
          emit(ProfileMeLoading());
          try {
            final profile = await getProfileMe();
            emit(ProfileMeLoaded(profile));
          } catch (e) {
            // If profile loading fails, still show user as authenticated
            emit(UserProfileExists(authContext));
          }
        } else {
          emit(UserProfileNotFound(authContext));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Prevent multiple simultaneous refresh requests
    if (_isRefreshingToken) {
      return;
    }

    _isRefreshingToken = true;

    try {
      final currentContext = await checkAuthStatus();
      if (currentContext != null) {
        final newTokens = await refreshToken(
          currentContext.tokens.refreshToken,
        );

        final updatedContext = AuthContext(
          accountId: currentContext.accountId,
          phoneNumber: currentContext.phoneNumber,
          tokens: newTokens,
        );

        // Maintain current profile state when refreshing tokens
        // DO NOT refetch profile data - it should only be fetched once on app start
        if (state is ProfileMeLoaded) {
          // Keep existing profile data, just update the auth context if needed
          final currentProfile = (state as ProfileMeLoaded).profile;
          emit(ProfileMeLoaded(currentProfile));
        } else if (state is UserProfileExists) {
          emit(UserProfileExists(updatedContext));
        } else if (state is UserProfileNotFound) {
          emit(UserProfileNotFound(updatedContext));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    } finally {
      _isRefreshingToken = false;
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    // Clear tokens will be handled by auth service
    emit(Unauthenticated());
  }

  Future<void> _onCheckUserProfile(
    CheckUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final profileExists = await checkUserProfile(event.accountId);
      final authContext = await checkAuthStatus();

      if (authContext != null) {
        if (profileExists) {
          emit(UserProfileExists(authContext));
        } else {
          emit(UserProfileNotFound(authContext));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGetProfileMe(
    GetProfileMeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ProfileMeLoading());
    try {
      final profile = await getProfileMe();
      emit(ProfileMeLoaded(profile));
    } catch (e) {
      emit(ProfileMeError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ProfileMeLoading());
    try {
      await updateProfile(event.profileData);
      final profile = await getProfileMe();
      emit(ProfileMeLoaded(profile));
    } catch (e) {
      emit(ProfileMeError(e.toString()));
    }
  }
}
