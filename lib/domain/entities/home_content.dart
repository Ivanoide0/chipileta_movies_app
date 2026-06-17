import 'movie.dart';

class HomeContent {
  final List<Movie> featured;
  final List<Movie> recommendations;
  final List<Movie> movies;
  final List<Movie> series;
  final Map<int, String> movieGenres;
  final Map<int, String> tvGenres;

  const HomeContent({
    required this.featured,
    required this.recommendations,
    required this.movies,
    required this.series,
    required this.movieGenres,
    required this.tvGenres,
  });
}
