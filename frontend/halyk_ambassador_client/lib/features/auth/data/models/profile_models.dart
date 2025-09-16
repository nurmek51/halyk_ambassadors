import '../../domain/entities/profile_entities.dart';

class ProfileDataModel extends ProfileData {
  const ProfileDataModel({
    required super.phoneNumber,
    required super.name,
    required super.surname,
    required super.position,
    required super.addressQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'name': name,
      'surname': surname,
      'position': position,
      'address_query': addressQuery,
    };
  }

  factory ProfileDataModel.fromEntity(ProfileData entity) {
    return ProfileDataModel(
      phoneNumber: entity.phoneNumber,
      name: entity.name,
      surname: entity.surname,
      position: entity.position,
      addressQuery: entity.addressQuery,
    );
  }

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      position: json['position'] as String,
      addressQuery: json['address_query'] as String,
    );
  }
}

class CityModel extends City {
  const CityModel({required super.id, required super.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.phoneNumber,
    required super.name,
    required super.surname,
    required super.position,
    required super.address,
    required super.fullName,
    required super.addressDisplay,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      position: json['position'] ?? '',
      address: AddressModel.fromJson(json['address'] ?? {}),
      fullName: json['full_name'] ?? '',
      addressDisplay: json['address_display'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class AddressModel extends Address {
  const AddressModel({
    required super.found,
    required super.address,
    required super.city,
    required super.region,
    required super.district,
    required super.postcode,
    required super.latitude,
    required super.longitude,
    required super.confidence,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      found: json['found'] ?? false,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      district: json['district'] ?? '',
      postcode: json['postcode'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      confidence: json['confidence'] ?? 0,
    );
  }
}
