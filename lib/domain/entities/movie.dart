class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final DateTime? releaseDate;

  // Campos nuevos para la pantalla Home.
  final String backdropPath;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    this.releaseDate,

    // Valores predeterminados para mantener compatibilidad.
    this.backdropPath = '',
    this.genreIds = const [],
  });
}