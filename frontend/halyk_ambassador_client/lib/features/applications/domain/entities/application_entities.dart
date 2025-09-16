import 'package:equatable/equatable.dart';

class Application extends Equatable {
  final String id;
  final String userProfileId;
  final ApplicationAddress address;
  final String description;
  final List<String> imageUrls;
  final String status;
  final String addressDisplay;
  final int imageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Application({
    required this.id,
    required this.userProfileId,
    required this.address,
    required this.description,
    required this.imageUrls,
    required this.status,
    required this.addressDisplay,
    required this.imageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userProfileId,
    address,
    description,
    imageUrls,
    status,
    addressDisplay,
    imageCount,
    createdAt,
    updatedAt,
  ];
}

class ApplicationAddress extends Equatable {
  final bool found;
  final String address;
  final String? amenity;
  final String road;
  final String? suburb;
  final String? cityDistrict;
  final String city;
  final String? region;
  final String? district;
  final String iso3166;
  final String postcode;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;
  final double confidence;

  const ApplicationAddress({
    required this.found,
    required this.address,
    this.amenity,
    required this.road,
    this.suburb,
    this.cityDistrict,
    required this.city,
    this.region,
    this.district,
    required this.iso3166,
    required this.postcode,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
    found,
    address,
    amenity,
    road,
    suburb,
    cityDistrict,
    city,
    region,
    district,
    iso3166,
    postcode,
    country,
    countryCode,
    latitude,
    longitude,
    confidence,
  ];
}

class CreateApplicationRequest extends Equatable {
  final String description;
  final List<String> imageUrls;
  final String addressQuery;
  final double latitude;
  final double longitude;

  const CreateApplicationRequest({
    required this.description,
    required this.imageUrls,
    required this.addressQuery,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    description,
    imageUrls,
    addressQuery,
    latitude,
    longitude,
  ];
}

class GeocodeResult extends Equatable {
  final bool success;
  final List<GeocodeAddress> results;

  const GeocodeResult({required this.success, required this.results});

  @override
  List<Object?> get props => [success, results];
}

class GeocodeAddress extends Equatable {
  final String displayName;
  final String lat;
  final String lon;
  final double importance;
  final AddressComponents address;

  const GeocodeAddress({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.importance,
    required this.address,
  });

  @override
  List<Object?> get props => [displayName, lat, lon, importance, address];
}

class AddressComponents extends Equatable {
  final String? houseNumber;
  final String road;
  final String cityDistrict;
  final String city;
  final String iso3166;
  final String postcode;
  final String country;
  final String countryCode;

  const AddressComponents({
    this.houseNumber,
    required this.road,
    required this.cityDistrict,
    required this.city,
    required this.iso3166,
    required this.postcode,
    required this.country,
    required this.countryCode,
  });

  @override
  List<Object?> get props => [
    houseNumber,
    road,
    cityDistrict,
    city,
    iso3166,
    postcode,
    country,
    countryCode,
  ];
}

class GeolocationRequest extends Equatable {
  final double latitude;
  final double longitude;
  final int zoom;

  const GeolocationRequest({
    required this.latitude,
    required this.longitude,
    this.zoom = 18,
  });

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}

class GeolocationResult extends Equatable {
  final bool success;
  final String displayName;
  final AddressComponents address;
  final String lat;
  final String lon;

  const GeolocationResult({
    required this.success,
    required this.displayName,
    required this.address,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [success, displayName, address, lat, lon];
}
