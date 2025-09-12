import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RequestOtpEvent extends AuthEvent {
  final String phoneNumber;

  const RequestOtpEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpEvent({required this.phoneNumber, required this.otpCode});

  @override
  List<Object> get props => [phoneNumber, otpCode];
}

class ClearErrorEvent extends AuthEvent {}

class ResendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const ResendOtpEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}
