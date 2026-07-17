import 'package:qde_realme/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name = '',
    super.city = '',
    super.district = '',
    super.number = '',
    super.isModerated = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      district: (json['district'] ?? '') as String,
      number: (json['number'] ?? '') as String,
      isModerated: (json['isModerated'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'city': city,
      'district': district,
      'number': number,
      'isModerated': isModerated,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      city: city,
      district: district,
      number: number,
      isModerated: isModerated,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? city,
    String? district,
    String? number,
    bool? isModerated,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      city: city ?? this.city,
      district: district ?? this.district,
      number: number ?? this.number,
      isModerated: isModerated ?? this.isModerated,
    );
  }
}
