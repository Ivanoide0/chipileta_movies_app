import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms
  });

  Future<User> login({
    required String email,
    required String password
  });

  Future<User> updateUsername({
    required int userId,
    required String newName,
    required String newLastName
  });

  Future<User> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword
  });

  Future<User> updatePhoto({
    required int userId,
    required String? photoPath
  });

  Future<User> signInWithGoogle();
}