import 'package:equatable/equatable.dart';

class ProfileData extends Equatable {
  final String phoneNumber;
  final String name;
  final String surname;
  final String position;
  final String addressQuery;

  const ProfileData({
    required this.phoneNumber,
    required this.name,
    required this.surname,
    required this.position,
    required this.addressQuery,
  });

  @override
  List<Object> get props => [
    phoneNumber,
    name,
    surname,
    position,
    addressQuery,
  ];
}

class City extends Equatable {
  final String id;
  final String name;

  const City({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}

class UserProfile extends Equatable {
  final String id;
  final String phoneNumber;
  final String name;
  final String surname;
  final String position;
  final Address address;
  final String fullName;
  final String addressDisplay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.surname,
    required this.position,
    required this.address,
    required this.fullName,
    required this.addressDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id,
    phoneNumber,
    name,
    surname,
    position,
    address,
    fullName,
    addressDisplay,
    createdAt,
    updatedAt,
  ];
}

class Address extends Equatable {
  final bool found;
  final String address;
  final String city;
  final String region;
  final String district;
  final String postcode;
  final double latitude;
  final double longitude;
  final int confidence;

  const Address({
    required this.found,
    required this.address,
    required this.city,
    required this.region,
    required this.district,
    required this.postcode,
    required this.latitude,
    required this.longitude,
    required this.confidence,
  });

  @override
  List<Object> get props => [
    found,
    address,
    city,
    region,
    district,
    postcode,
    latitude,
    longitude,
    confidence,
  ];
}
