import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class AddNotificationUseCase {
  final NotificationsRepository repository;

  AddNotificationUseCase(this.repository);

  Future<AppNotification> call({
    required int movieId,
    required String movieTitle,
    required String moviePoster,
    required NotificationType type,
  }) {
    return repository.add(
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      type: type,
    );
  }
}
