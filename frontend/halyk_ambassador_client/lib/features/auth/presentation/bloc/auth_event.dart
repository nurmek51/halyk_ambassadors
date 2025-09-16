import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entities.dart';

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

class ResendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const ResendOtpEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class CreateProfileEvent extends AuthEvent {
  final ProfileData profileData;

  const CreateProfileEvent(this.profileData);

  @override
  List<Object> get props => [profileData];
}

class LoadCitiesEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class RefreshTokenEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class CheckUserProfileEvent extends AuthEvent {
  final String accountId;

  const CheckUserProfileEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class GetProfileMeEvent extends AuthEvent {}
