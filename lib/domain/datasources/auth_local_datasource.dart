import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/user_model.dart';
import 'database_helper.dart';
import 'google_auth_service.dart';

class AuthLocalDataSource {
  final DatabaseHelper dbHelper;
  
  AuthLocalDataSource(this.dbHelper);

  Future<UserModel> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms,
    int rolId = 2,
  }) async {
    if (!acceptTerms) {
      throw Exception('Debes aceptar los términos y condiciones.');
    }

    final db = await dbHelper.database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existing.isNotEmpty){
      throw Exception('El correo ya esta registrado.');
    }

    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final now = DateTime.now();

    final user = UserModel(
      name: name,
      lastName: lastName,
      email: email,
      passwordHash: passwordHash,
      telephone: telephone,
      acceptTerms: acceptTerms,
      rolId: rolId,
      isActive: true,
      createdAt: now,
    );

    final id = await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return UserModel(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      passwordHash: passwordHash,
      telephone: telephone,
      acceptTerms: acceptTerms,
      rolId: rolId,
      isActive: true,
      createdAt: now,
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if(result.isEmpty){
      throw Exception('Usuario no encontrado.');
    }

    final user = UserModel.fromMap(result.first);

    if(!user.isActive){
      throw Exception('Usuario inactivo. Contacta al soporte.');
    }

    if(user.passwordHash == null){
      throw Exception(
        'Esta cuenta usa inicio de sesión con Google'
      );
    }

    final passwordOk = BCrypt.checkpw(password, user.passwordHash!);
    if(!passwordOk){
      throw Exception('Contraseña incorrecta.');
    }

    return user;
  }

  Future<UserModel> loginOrRegisterWithGoogle(
    GoogleAccountData google,
  ) async{
    final db = await dbHelper.database;
    final email = google.email.trim().toLowerCase();
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if(existing.isNotEmpty){
      final user = UserModel.fromMap(existing.first);

      if(!user.isActive){
        throw Exception('Usuario inactivo. Contacta al soporte (Raúl).');
      }

      if((existing.first['google_id'] as String?) == null){
        await db.update(
          'users',
          {'google_id': google.googleId},
          where: 'id = ?',
          whereArgs: [user.id]
        );
      }

      return user;
    }

    final now = DateTime.now();
    final nameParts = _splitDisplayName(google.displayName, email);

    final newUser = UserModel(
      name: nameParts.$1,
      lastName: nameParts.$2,
      email: email,
      passwordHash: null,
      telephone: '',
      acceptTerms: true,
      rolId: 2,
      isActive: true,
      createdAt: now,
      googleId: google.googleId
    );

    final id = await db.insert(
      'users',
      newUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort
    );

    return UserModel(
      name: nameParts.$1,
      lastName: nameParts.$2,
      email: email,
      passwordHash: null,
      telephone: '',
      acceptTerms: true,
      rolId: 2,
      isActive: true,
      createdAt: now,
      googleId: google.googleId
    );
  }

  (String, String) _splitDisplayName(String? displayName, String email){
    final full = (displayName ?? '').trim();
    if(full.isEmpty){
      final local = email.split('@').first;
      return (local, '');
    }

    final parts = full.split(RegExp(r'\s+'));
    if(parts.length == 1){
      return (parts.first, '');
    }

    final first = parts.first;
    final last = parts.sublist(1).join(' ');
    return (first, last);
  }
}