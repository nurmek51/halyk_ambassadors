import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/profile_entities.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phoneNumber;

  const OtpSent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class OtpVerified extends AuthState {
  final AuthContext authContext;

  const OtpVerified(this.authContext);

  @override
  List<Object> get props => [authContext];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class OtpError extends AuthState {
  final String message;
  final String phoneNumber;

  const OtpError({required this.message, required this.phoneNumber});

  @override
  List<Object> get props => [message, phoneNumber];
}

class CitiesLoaded extends AuthState {
  final List<City> cities;

  const CitiesLoaded(this.cities);

  @override
  List<Object> get props => [cities];
}

class ProfileCreated extends AuthState {}

class ProfileError extends AuthState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class Authenticated extends AuthState {
  final AuthContext authContext;

  const Authenticated(this.authContext);

  @override
  List<Object> get props => [authContext];
}

class Unauthenticated extends AuthState {}

class UserProfileExists extends AuthState {
  final AuthContext authContext;

  const UserProfileExists(this.authContext);

  @override
  List<Object> get props => [authContext];
}

class UserProfileNotFound extends AuthState {
  final AuthContext authContext;

  const UserProfileNotFound(this.authContext);

  @override
  List<Object> get props => [authContext];
}

class ProfileMeLoaded extends AuthState {
  final UserProfile profile;

  const ProfileMeLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileMeLoading extends AuthState {}

class ProfileMeError extends AuthState {
  final String message;

  const ProfileMeError(this.message);

  @override
  List<Object> get props => [message];
}
