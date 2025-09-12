import '../../domain/entities/auth_entities.dart';

class OtpRequestModel extends OtpRequest {
  const OtpRequestModel({required super.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber};
  }

  factory OtpRequestModel.fromEntity(OtpRequest entity) {
    return OtpRequestModel(phoneNumber: entity.phoneNumber);
  }
}

class OtpVerificationModel extends OtpVerification {
  const OtpVerificationModel({
    required super.phoneNumber,
    required super.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'otp_code': otpCode};
  }

  factory OtpVerificationModel.fromEntity(OtpVerification entity) {
    return OtpVerificationModel(
      phoneNumber: entity.phoneNumber,
      otpCode: entity.otpCode,
    );
  }
}

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
