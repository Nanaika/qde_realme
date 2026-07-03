import 'package:qde_realme/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.number,
    super.isModerated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      number: json['number'] as String,
      isModerated: json['isModerated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'number': number,
      'isModerated': isModerated,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      number: number,
      isModerated: isModerated,
    );
  }
}

