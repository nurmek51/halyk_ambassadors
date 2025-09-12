import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entities.dart';

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

class AuthAuthenticated extends AuthState {
  final AuthTokens tokens;

  const AuthAuthenticated(this.tokens);

  @override
  List<Object> get props => [tokens];
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
