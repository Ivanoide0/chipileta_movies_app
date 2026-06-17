import '../entities/movie.dart';
import '../entities/review.dart';
import '../repositories/movies_repository.dart';

class GetTopReviewsUseCase {
  final MoviesRepository repository;

  GetTopReviewsUseCase(this.repository);

  Future<List<Review>> call({
    required List<Movie> movies,
    int maxMovies = 8,
    int limit = 5,
  }) async {
    final sample = movies.take(maxMovies).toList();

    final results = await Future.wait(
      sample.map((m) => _safeReviews(m.id)),
    );

    final all = results.expand((list) => list).toList();
    final rated = all.where((r) => r.rating != null).toList();
    rated.sort((a, b) => b.rating!.compareTo(a.rating!));

    return rated.take(limit).toList();
  }

  Future<List<Review>> _safeReviews(int movieId) async {
    try {
      return await repository.getMovieReviews(movieId);
    } catch (_) {
      return const [];
    }
  }
}