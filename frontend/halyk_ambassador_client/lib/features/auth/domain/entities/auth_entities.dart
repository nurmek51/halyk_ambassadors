import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  @override
  List<Object> get props => [accessToken, refreshToken];
}

class AuthContext extends Equatable {
  final String accountId;
  final String phoneNumber;
  final AuthTokens tokens;

  const AuthContext({
    required this.accountId,
    required this.phoneNumber,
    required this.tokens,
  });

  @override
  List<Object> get props => [accountId, phoneNumber, tokens];
}

class OtpRequest extends Equatable {
  final String phoneNumber;

  const OtpRequest({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class OtpVerification extends Equatable {
  final String phoneNumber;
  final String otpCode;

  const OtpVerification({required this.phoneNumber, required this.otpCode});

  @override
  List<Object> get props => [phoneNumber, otpCode];
}
