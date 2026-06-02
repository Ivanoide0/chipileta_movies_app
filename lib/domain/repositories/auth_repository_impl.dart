import '../entities/user.dart';
import 'auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<User> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms
  }) async {
    final userModel = await localDataSource.register(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      telephone: telephone,
      acceptTerms: acceptTerms
    );
    return userModel.toEntity();
  }

  @override
  Future<User> login({
    required String email,
    required String password
  }) async {
    final userModel = await localDataSource.login(
      email: email,
      password: password
    );
    return userModel.toEntity();
  }
}