import '../repositories/notifications_repository.dart';

class ClearNotificationsUseCase {
  final NotificationsRepository repository;

  ClearNotificationsUseCase(this.repository);

  Future<void> call() => repository.clearAll();
}