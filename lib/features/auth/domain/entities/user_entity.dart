import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String number;
  final bool isModerated;
  final String? name;
  final String? city;
  final String? district;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.city,
    this.district,
    this.number = '',
    this.isModerated = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    number,
    isModerated,
    name,
    city,
    district,
  ];
}
