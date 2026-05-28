import '../../entities/user.dart';

class UserModel extends User {
  final String passwordHash;

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
    required this.passwordHash,
  });

  Map<String, dynamic>toMap()=>{
    'id': id,
    'nombre': name,
    'apellido': lastName,
    'email': email,
    'password': passwordHash,
    'telefono': telephone,
    'acepto_terminos': acceptTerms ? 1 : 0,
    'rol_id': rolId,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    name: map['nombre'] as String,
    lastName: map['apellido'] as String,
    email: map['email'] as String,
    passwordHash: map['password'] as String,
    telephone: map['telefono'] as String,
    acceptTerms: (map['acepto_terminos'] as int == 1),
    rolId: map['rol_id'] as int,
    isActive: (map['is_active'] as int == 1),
    createdAt: DateTime.parse(map['created_at'] as String),
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
  );
}