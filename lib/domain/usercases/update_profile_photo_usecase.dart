import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfilePhotoUseCase {
  final AuthRepository repository;

  UpdateProfilePhotoUseCase(this.repository);

  Future<User> call({
    required int userId,
    required String? photoPath,
  }) {
    return repository.updatePhoto(
      userId: userId,
      photoPath: photoPath,
    );
  }
}