import '../../entities/rol.dart';

class RolModel extends Rol{
  const RolModel({super.id, required super.rol});

  Map<String, dynamic> toMap() => {
    'id': id,
    'rol': rol,
  };

  factory RolModel.fromMap(Map<String, dynamic> map) => RolModel(
    id: map['id'] as int?,
    rol: map['rol'] as String,
  );

  Rol toEntity() => Rol(id:id, rol: rol);
}