import '../../entities/movie.dart';

class MovieModel extends Movie{
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.voteAverage,
    super.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    overview: json['overview'] as String? ?? '', 
    posterPath: json['poster_path'] as String? ?? '',
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    releaseDate: _parseDate(json['release_date'] as String?)
  );

  static DateTime? _parseDate(String? value){
    if(value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview, 
    posterPath: posterPath,
    voteAverage: voteAverage,
    releaseDate: releaseDate
  );
}