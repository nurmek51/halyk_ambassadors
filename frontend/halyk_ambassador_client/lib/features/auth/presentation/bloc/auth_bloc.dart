import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/create_profile.dart';
import '../../domain/usecases/refresh_token.dart';
import '../../domain/usecases/check_user_profile.dart';
import '../../domain/usecases/get_profile_me.dart';
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

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.createProfile,
    required this.getCities,
    required this.refreshToken,
    required this.checkAuthStatus,
    required this.checkUserProfile,
    required this.getProfileMe,
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

      // Create auth context for navigation to profile creation
      String accountId = 'temp_account_id'; // fallback
      if (tokens is AuthTokensModel && tokens.accountId != null) {
        accountId = tokens.accountId!;
      }

      final authContext = AuthContext(
        accountId: accountId,
        phoneNumber: event.phoneNumber,
        tokens: tokens,
      );

      emit(OtpVerified(authContext));
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
      emit(ProfileCreated());
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
    try {
      final authContext = await checkAuthStatus();
      if (authContext != null) {
        emit(Authenticated(authContext));
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
        emit(Authenticated(updatedContext));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
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
}
