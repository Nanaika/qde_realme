import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String number;
  final bool isModerated;

  const UserEntity({
    required this.id,
    required this.email,
    this.number = '',
    this.isModerated = false,
  });

  @override
  List<Object?> get props => [id, email, number, isModerated];
}

