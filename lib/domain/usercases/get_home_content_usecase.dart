import '../entities/home_content.dart';
import '../repositories/movies_repository.dart';

class GetHomeContentUseCase {
  final MoviesRepository repository;

  GetHomeContentUseCase(this.repository);

  Future<HomeContent> call() async {
    final nowPlayingFuture = repository.getNowPlaying();
    final popularMoviesFuture = repository.getPopularMovies();
    final popularSeriesFuture = repository.getPopularSeries();
    final movieGenresFuture = repository.getMovieGenres();
    final tvGenresFuture = repository.getTvGenres();

    final nowPlaying = await nowPlayingFuture;
    final popularMovies = await popularMoviesFuture;
    final popularSeries = await popularSeriesFuture;
    final movieGenres = await movieGenresFuture;
    final tvGenres = await tvGenresFuture;

    final featured = nowPlaying.isNotEmpty
        ? nowPlaying
        : popularMovies;

    final recommendations = popularMovies.isNotEmpty
        ? popularMovies
        : nowPlaying;

    return HomeContent(
      featured: featured,
      recommendations: recommendations,
      movies: nowPlaying,
      series: popularSeries,
      movieGenres: movieGenres,
      tvGenres: tvGenres,
    );
  }
}