import '../../entities/user.dart';

class UserModel extends User {
  final String? googleId;

  const UserModel({
    super.id,
    required super.name,
    required super.lastName,
    required super.email,
    required super.telephone,
    required super.acceptTerms,
    required super.isActive,
    required super.createdAt,
    required super.rolId,
    super.photoPath,
    this.googleId,
  });

  Map<String, dynamic> toFirestoreMap() => {
    'nombre': name,
    'apellido': lastName,
    'email': email,
    'telefono': telephone,
    'acepto_terminos': acceptTerms,
    'rol_id': rolId,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'google_id': googleId,
    'foto_perfil': photoPath,
  };

  factory UserModel.fromFirestore(String id, Map<String, dynamic> map) => UserModel(
    id: id,
    name: map['nombre'] as String,
    lastName: map['apellido'] as String,
    email: map['email'] as String,
    telephone: map['telefono'] as String? ?? '',
    acceptTerms: (map['acepto_terminos'] as bool?) ?? false,
    rolId: (map['rol_id'] as int?) ?? 2,
    isActive: (map['is_active'] as bool?) ?? true,
    createdAt: DateTime.parse(map['created_at'] as String),
    googleId: map['google_id'] as String?,
    photoPath: map['foto_perfil'] as String?,
  );

  User toEntity() => User(
    id: id,
    name: name,
    lastName: lastName,
    email: email,
    telephone: telephone,
    acceptTerms: acceptTerms,
    rolId: rolId,
    isActive: isActive,
    createdAt: createdAt,
    photoPath: photoPath,
  );
}