import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;

  AuthBloc({required this.requestOtp, required this.verifyOtp})
    : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ClearErrorEvent>(_onClearError);
    on<ResendOtpEvent>(_onResendOtp);
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
      emit(AuthAuthenticated(tokens));
    } catch (e) {
      emit(OtpError(message: e.toString(), phoneNumber: event.phoneNumber));
    }
  }

  void _onClearError(ClearErrorEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
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
}
