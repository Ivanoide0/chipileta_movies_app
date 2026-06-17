import '../../entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required int id,
    required String title,
    required String overview,
    required String posterPath,
    required double voteAverage,
    DateTime? releaseDate,
    String backdropPath = '',
    List<int> genreIds = const [],
  }) : super(
          id: id,
          title: title,
          overview: overview,
          posterPath: posterPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
          backdropPath: backdropPath,
          genreIds: genreIds,
        );

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final rawGenreIds = json['genre_ids'];

    final genreIds = rawGenreIds is List
        ? rawGenreIds
            .whereType<num>()
            .map((genreId) => genreId.toInt())
            .toList(growable: false)
        : const <int>[];

    final title = (json['title'] as String?) ??
        (json['name'] as String?) ??
        '';

    final releaseDateValue = (json['release_date'] as String?) ??
        (json['first_air_date'] as String?);

    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: title,
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: genreIds,
      releaseDate: _parseDate(releaseDateValue),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      backdropPath: backdropPath,
      genreIds: genreIds,
    );
  }
}