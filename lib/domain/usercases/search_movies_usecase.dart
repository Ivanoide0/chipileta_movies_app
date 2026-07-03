import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class SearchMoviesUseCase {
  final MoviesRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<List<Movie>> call(String query) {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return Future.value(const []);
    }

    return repository.searchMovies(trimmed);
  }
}