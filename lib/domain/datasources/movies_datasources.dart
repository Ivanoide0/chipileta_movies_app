import '../entities/movie.dart';
import '../entities/review.dart';

abstract class MoviesDatasource {
  Future<List<Movie>> getNowPlaying();

  Future<List<Movie>> getPopularMovies();

  Future<List<Movie>> getPopularSeries();

  Future<List<Review>> getMovieReviews(int movieId);

  Future<Map<int, String>> getMovieGenres();

  Future<Map<int, String>> getTvGenres();
}