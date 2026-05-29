import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms,
  });
}