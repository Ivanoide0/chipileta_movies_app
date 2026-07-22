import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUsernameUseCase {
  final AuthRepository repository;

  UpdateUsernameUseCase(this.repository);

  Future<User> call({
    required int userId,
    required String newName,
    required String newLastName,
  }) {
    return repository.updateUsername(
      userId: userId,
      newName: newName,
      newLastName: newLastName,
    );
  }
}