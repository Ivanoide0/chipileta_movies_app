import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUsecase{
  final AuthRepository repository;
  UpdatePasswordUsecase(this.repository);

  Future<User> call({
    required String userId,
    required String currentPassword,
    required String newPassword
  }){
    return repository.updatePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword
    );
  }
}