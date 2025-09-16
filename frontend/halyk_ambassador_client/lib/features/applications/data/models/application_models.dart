import '../../domain/entities/application_entities.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.userProfileId,
    required super.address,
    required super.description,
    required super.imageUrls,
    required super.status,
    required super.addressDisplay,
    required super.imageCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? '',
      userProfileId: json['user_profile_id'] ?? '',
      address: ApplicationAddressModel.fromJson(json['address'] ?? {}),
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      status: json['status'] ?? '',
      addressDisplay: json['address_display'] ?? '',
      imageCount: json['image_count'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ApplicationAddressModel extends ApplicationAddress {
  const ApplicationAddressModel({
    required super.found,
    required super.address,
    super.amenity,
    required super.road,
    super.suburb,
    super.cityDistrict,
    required super.city,
    super.region,
    super.district,
    required super.iso3166,
    required super.postcode,
    required super.country,
    required super.countryCode,
    required super.latitude,
    required super.longitude,
    required super.confidence,
  });

  factory ApplicationAddressModel.fromJson(Map<String, dynamic> json) {
    return ApplicationAddressModel(
      found: json['found'] ?? false,
      address: json['address'] ?? '',
      amenity: json['amenity'],
      road: json['road'] ?? '',
      suburb: json['suburb'],
      cityDistrict: json['city_district'],
      city: json['city'] ?? '',
      region: json['region'],
      district: json['district'],
      iso3166: json['iso3166_2_lvl4'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class CreateApplicationRequestModel extends CreateApplicationRequest {
  const CreateApplicationRequestModel({
    required super.description,
    required super.imageUrls,
    required super.addressQuery,
    required super.latitude,
    required super.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'image_urls': imageUrls,
      'address_query': addressQuery,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory CreateApplicationRequestModel.fromEntity(
    CreateApplicationRequest entity,
  ) {
    return CreateApplicationRequestModel(
      description: entity.description,
      imageUrls: entity.imageUrls,
      addressQuery: entity.addressQuery,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}

class GeocodeResultModel extends GeocodeResult {
  const GeocodeResultModel({required super.success, required super.results});

  factory GeocodeResultModel.fromJson(Map<String, dynamic> json) {
    return GeocodeResultModel(
      success: json['success'] ?? false,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((result) => GeocodeAddressModel.fromJson(result))
              .toList() ??
          [],
    );
  }
}

class GeocodeAddressModel extends GeocodeAddress {
  const GeocodeAddressModel({
    required super.displayName,
    required super.lat,
    required super.lon,
    required super.importance,
    required super.address,
  });

  factory GeocodeAddressModel.fromJson(Map<String, dynamic> json) {
    return GeocodeAddressModel(
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',
      importance: (json['importance'] ?? 0).toDouble(),
      address: AddressComponentsModel.fromJson(json['address'] ?? {}),
    );
  }
}

class AddressComponentsModel extends AddressComponents {
  const AddressComponentsModel({
    super.houseNumber,
    required super.road,
    required super.cityDistrict,
    required super.city,
    required super.iso3166,
    required super.postcode,
    required super.country,
    required super.countryCode,
  });

  factory AddressComponentsModel.fromJson(Map<String, dynamic> json) {
    return AddressComponentsModel(
      houseNumber: json['house_number'],
      road: json['road'] ?? '',
      cityDistrict: json['city_district'] ?? '',
      city: json['city'] ?? '',
      iso3166: json['ISO3166-2-lvl4'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }
}

class GeolocationRequestModel extends GeolocationRequest {
  const GeolocationRequestModel({
    required super.latitude,
    required super.longitude,
    super.zoom = 18,
  });

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'zoom': zoom};
  }

  factory GeolocationRequestModel.fromEntity(GeolocationRequest entity) {
    return GeolocationRequestModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      zoom: entity.zoom,
    );
  }
}

class GeolocationResultModel extends GeolocationResult {
  const GeolocationResultModel({
    required super.success,
    required super.displayName,
    required super.address,
    required super.lat,
    required super.lon,
  });

  factory GeolocationResultModel.fromJson(Map<String, dynamic> json) {
    return GeolocationResultModel(
      success: json['success'] ?? false,
      displayName: json['display_name'] ?? '',
      address: AddressComponentsModel.fromJson(json['address'] ?? {}),
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',
    );
  }
}
