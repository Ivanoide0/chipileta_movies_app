import 'review.dart';

class CastMember {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath = '',
  });
}

class MovieVideo {
  final String key;
  final String name;
  final String type;

  const MovieVideo({
    required this.key,
    required this.name,
    required this.type,
  });

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$key/hqdefault.jpg';
}

class Movie {
  final int id;

  final String mediaType;

  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final DateTime? releaseDate;
  final String backdropPath;
  final List<int> genreIds;

  final int? runtime;
  final List<String> genres;
  final String trailerKey;
  final List<CastMember> cast;
  final List<Review> tmdbReviews;
  final List<MovieVideo> videos;
  final List<String> backdrops;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.mediaType = 'movie',
    this.backdropPath = '',
    this.genreIds = const [],
    this.runtime,
    this.genres = const [],
    this.trailerKey = '',
    this.cast = const [],
    this.tmdbReviews = const [],
    this.videos = const [],
    this.backdrops = const []
  }) : assert(
          mediaType == 'movie' || mediaType == 'tv',
          'mediaType debe ser "movie" o "tv"',
        );

  bool get isTv => mediaType == 'tv';
  bool get isMovie => mediaType == 'movie';
  String get storageKey => '$mediaType:$id';

  int get opinionId => isTv ? -id : id;

  bool get hasTrailer => trailerKey.isNotEmpty;

  bool get hasExtras => videos.isNotEmpty || backdrops.isNotEmpty;

  bool get hasCast => cast.isNotEmpty;

  String get mediaTypeLabel => isTv ? 'Serie' : 'Película';

  Movie copyWith({
    int? id,
    String? mediaType,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    DateTime? releaseDate,
    String? backdropPath,
    List<int>? genreIds,
    int? runtime,
    List<String>? genres,
    String? trailerKey,
    List<CastMember>? cast,
    List<Review>? tmdbReviews,
    List<MovieVideo>? videos,
    List<String>? backdrops,
  }) {
    return Movie(
      id: id ?? this.id,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      backdropPath: backdropPath ?? this.backdropPath,
      genreIds: genreIds ?? this.genreIds,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      trailerKey: trailerKey ?? this.trailerKey,
      cast: cast ?? this.cast,
      tmdbReviews: tmdbReviews ?? this.tmdbReviews,
      videos: videos ?? this.videos,
      backdrops: backdrops ?? this.backdrops,
    );
  }
}