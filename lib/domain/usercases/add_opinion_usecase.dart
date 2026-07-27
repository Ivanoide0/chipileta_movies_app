import '../entities/opinion.dart';
import '../repositories/opinions_repository.dart';

class AddOpinionUseCase {
  final OpinionsRepository repository;

  AddOpinionUseCase(this.repository);

  Future<Opinion> call({
    required int movieId,
    required String userId,
    required double rating,
    required String comment,
    required String authorName,
    required String authorLastName,
    String? authorPhotoPath,
  }) {
    final text = comment.trim();

    if (text.isEmpty) {
      throw Exception('La opinión no puede estar vacía.');
    }

    if (rating < 0 || rating > 5) {
      throw Exception('La calificación debe estar entre 0 y 5.');
    }

    return repository.addOpinion(
      movieId: movieId,
      userId: userId,
      rating: rating,
      comment: text,
      authorName: authorName,
      authorLastName: authorLastName,
      authorPhotoPath: authorPhotoPath,
    );
  }
}