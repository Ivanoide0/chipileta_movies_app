import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms
  }) {
    return repository.register(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      telephone: telephone,
      acceptTerms: acceptTerms
    );
  }
}