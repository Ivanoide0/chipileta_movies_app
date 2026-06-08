import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class GetNowPlayingUseCase {
  final MoviesRepository repository;

  GetNowPlayingUseCase(this.repository);

  Future<List<Movie>> call() {
    return repository.getNowPlaying();
  }
}