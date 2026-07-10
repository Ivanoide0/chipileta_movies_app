import '../repositories/notifications_repository.dart';

class MarkNotificationsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationsReadUseCase(this.repository);

  Future<void> call() => repository.markAllRead();
}
