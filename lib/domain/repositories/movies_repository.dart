import '../entities/movie.dart';
import '../entities/review.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying();

  Future<List<Movie>> getPopularMovies();

  Future<List<Movie>> getPopularSeries();

  Future<Map<int, String>> getMovieGenres();

  Future<Map<int, String>> getTvGenres();

  Future<List<Review>> getMovieReviews(int movieId);
}