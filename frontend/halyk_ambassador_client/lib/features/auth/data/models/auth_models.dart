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
  final String? accountId;
  final String? phoneNumber;

  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    this.accountId,
    this.phoneNumber,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    // Handle nested tokens structure from API response
    final tokens = json['tokens'] as Map<String, dynamic>?;
    if (tokens != null) {
      return AuthTokensModel(
        accessToken: tokens['access'] as String? ?? '',
        refreshToken: tokens['refresh'] as String? ?? '',
        accountId: json['account_id'] as String?,
        phoneNumber: json['phone_number'] as String?,
      );
    } else {
      // Fallback for direct token structure
      return AuthTokensModel(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
        accountId: json['account_id'] as String?,
        phoneNumber: json['phone_number'] as String?,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      if (accountId != null) 'account_id': accountId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
