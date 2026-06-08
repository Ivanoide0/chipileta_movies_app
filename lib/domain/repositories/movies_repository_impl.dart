import '../entities/movie.dart';
import 'movies_repository.dart';
import '../datasources/movies_datasources.dart';

class MoviesRepositoryImpl implements MoviesRepository{
  final MoviesDatasource datasource;

  MoviesRepositoryImpl(this.datasource);

  @override
  Future<List<Movie>> getNowPlaying(){
    return datasource.getNowPlaying();
  }
}