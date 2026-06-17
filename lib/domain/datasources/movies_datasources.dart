import '../entities/movie.dart';

abstract class MoviesDatasource {
  Future<List<Movie>> getNowPlaying();

  Future<List<Movie>> getPopularMovies();

  Future<List<Movie>> getPopularSeries();

  Future<Map<int, String>> getMovieGenres();

  Future<Map<int, String>> getTvGenres();
}