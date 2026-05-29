import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/user_model.dart';
import 'database_helper.dart';

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
}