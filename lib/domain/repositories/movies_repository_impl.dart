import '../datasources/movies_datasources.dart';
import '../entities/movie.dart';
import 'movies_repository.dart';
import '../entities/review.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesDatasource datasource;

  MoviesRepositoryImpl(this.datasource);

  // Método existente: mantiene el mismo comportamiento.
  @override
  Future<List<Movie>> getNowPlaying() {
    return datasource.getNowPlaying();
  }

  // Métodos nuevos para la pantalla Home.
  @override
  Future<List<Movie>> getPopularMovies() {
    return datasource.getPopularMovies();
  }

  @override
  Future<List<Movie>> getPopularSeries() {
    return datasource.getPopularSeries();
  }

  @override
  Future<Map<int, String>> getMovieGenres() {
    return datasource.getMovieGenres();
  }

  @override
  Future<Map<int, String>> getTvGenres() {
    return datasource.getTvGenres();
  }

  @override
  Future<List<Review>> getMovieReviews(int movieId) {
    return datasource.getMovieReviews(movieId);
  }

  @override
  Future<List<Movie>> searchMovies(String query){
    return datasource.searchMovies(query);
  }
}