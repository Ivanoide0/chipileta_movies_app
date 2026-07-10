import '../repositories/notifications_repository.dart';

class DeleteNotificationUseCase {
  final NotificationsRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<void> call(int id) => repository.delete(id);
}