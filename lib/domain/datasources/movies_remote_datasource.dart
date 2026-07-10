import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/models/movie_model.dart';
import '../data/models/review_model.dart';
import '../entities/movie.dart';
import '../entities/review.dart';
import 'movies_datasources.dart';

class MoviesRemoteDatasource implements MoviesDatasource {
  final String _baseUrl = dotenv.env['TMDB_BASE_URL']!;
  final String _token = dotenv.env['TMDB_ACCESS_TOKEN']!;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'accept': 'application/json',
      };

  @override
  Future<List<Movie>> getNowPlaying() {
    return _getMovies(
      '/movie/now_playing',
      mediaType: 'movie',
    );
  }

  @override
  Future<List<Movie>> getPopularMovies() {
    return _getMovies(
      '/movie/popular',
      mediaType: 'movie',
    );
  }

  @override
  Future<List<Movie>> getPopularSeries() {
    return _getMovies(
      '/tv/popular',
      mediaType: 'tv',
    );
  }

  @override
  Future<Map<int, String>> getMovieGenres() {
    return _getGenres('/genre/movie/list');
  }

  @override
  Future<Map<int, String>> getTvGenres() {
    return _getGenres('/genre/tv/list');
  }

  @override
  Future<List<Review>> getMovieReviews(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId/reviews',
    ).replace(
      queryParameters: const {
        'language': 'en-US',
        'page': '1',
      },
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar reseñas (${response.statusCode})',
      );
    }

    final decoded =
        json.decode(response.body) as Map<String, dynamic>;

    return _parseReviews(decoded);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return const [];
    }

    final url = Uri.parse(
      '$_baseUrl/search/multi',
    ).replace(
      queryParameters: {
        'language': 'es-MX',
        'page': '1',
        'include_adult': 'false',
        'query': trimmed,
      },
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al buscar contenido (${response.statusCode})',
      );
    }

    final decoded =
        json.decode(response.body) as Map<String, dynamic>;

    final results =
        decoded['results'] as List<dynamic>? ?? const [];

    return results
        .whereType<Map<String, dynamic>>()
        .where((item) {
          final mediaType = item['media_type'];
          return mediaType == 'movie' || mediaType == 'tv';
        })
        .map((item) {
          final mediaType =
              item['media_type'] as String? ?? 'movie';

          return MovieModel.fromJson(item).copyWith(
            mediaType: mediaType,
          );
        })
        .toList(growable: false);
  }

  /// Obtiene todos los datos necesarios para la pantalla de detalle.
  ///
  /// Este método no necesita agregarse a MoviesDatasource porque será
  /// utilizado directamente por MediaDetailScreen.
  Future<Movie> getMediaDetail(Movie movie) async {
    final mediaType = movie.isTv ? 'tv' : 'movie';

    final spanishData = await _getDetailPayload(
      mediaType: mediaType,
      id: movie.id,
      language: 'es-MX',
    );

    String trailerKey = _selectTrailerKey(
      spanishData['videos'],
    );

    List<Review> reviews = _parseReviews(
      spanishData['reviews'],
    );

    /*
     * TMDB puede no tener tráiler o reseñas traducidos al español.
     * Solo en ese caso hacemos una segunda consulta en inglés.
     */
    if (trailerKey.isEmpty || reviews.isEmpty) {
      try {
        final englishData = await _getDetailPayload(
          mediaType: mediaType,
          id: movie.id,
          language: 'en-US',
        );

        if (trailerKey.isEmpty) {
          trailerKey = _selectTrailerKey(
            englishData['videos'],
          );
        }

        if (reviews.isEmpty) {
          reviews = _parseReviews(
            englishData['reviews'],
          );
        }
      } catch (_) {
        // La información principal en español ya fue obtenida.
        // Si el respaldo en inglés falla, la pantalla puede continuar.
      }
    }

    final creditsKey = movie.isTv
        ? 'aggregate_credits'
        : 'credits';

    final cast = _parseCast(
      spanishData[creditsKey],
      isTv: movie.isTv,
    );

    final genres = _parseGenreNames(
      spanishData['genres'],
    );

    final genreIds = _parseGenreIds(
      spanishData['genres'],
    );

    final releaseDateText = movie.isTv
        ? spanishData['first_air_date'] as String?
        : spanishData['release_date'] as String?;

    final title = movie.isTv
        ? spanishData['name'] as String?
        : spanishData['title'] as String?;

    return Movie(
      id: movie.id,
      mediaType: mediaType,
      title: _textOrFallback(
        title,
        movie.title,
      ),
      overview: _textOrFallback(
        spanishData['overview'] as String?,
        movie.overview,
      ),
      posterPath: _textOrFallback(
        spanishData['poster_path'] as String?,
        movie.posterPath,
      ),
      backdropPath: _textOrFallback(
        spanishData['backdrop_path'] as String?,
        movie.backdropPath,
      ),
      voteAverage:
          (spanishData['vote_average'] as num?)?.toDouble() ??
              movie.voteAverage,
      releaseDate:
          _parseDate(releaseDateText) ?? movie.releaseDate,
      genreIds:
          genreIds.isNotEmpty ? genreIds : movie.genreIds,
      runtime: _parseRuntime(
        spanishData,
        isTv: movie.isTv,
      ),
      genres: genres,
      trailerKey: trailerKey,
      cast: cast,
      tmdbReviews: reviews,
    );
  }

  Future<Map<String, dynamic>> _getDetailPayload({
    required String mediaType,
    required int id,
    required String language,
  }) async {
    final appendToResponse = mediaType == 'tv'
        ? 'videos,aggregate_credits,reviews'
        : 'videos,credits,reviews';

    final url = Uri.parse(
      '$_baseUrl/$mediaType/$id',
    ).replace(
      queryParameters: {
        'language': language,
        'append_to_response': appendToResponse,
      },
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar el detalle (${response.statusCode})',
      );
    }

    return json.decode(response.body)
        as Map<String, dynamic>;
  }

  Future<List<Movie>> _getMovies(
    String path, {
    required String mediaType,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$path',
    ).replace(
      queryParameters: const {
        'language': 'es-MX',
        'page': '1',
      },
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar contenido (${response.statusCode})',
      );
    }

    final decoded =
        json.decode(response.body) as Map<String, dynamic>;

    final results =
        decoded['results'] as List<dynamic>? ?? const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => MovieModel.fromJson(item).copyWith(
            mediaType: mediaType,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, String>> _getGenres(
    String path,
  ) async {
    final url = Uri.parse(
      '$_baseUrl$path',
    ).replace(
      queryParameters: const {
        'language': 'es-MX',
      },
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar géneros (${response.statusCode})',
      );
    }

    final decoded =
        json.decode(response.body) as Map<String, dynamic>;

    final genres =
        decoded['genres'] as List<dynamic>? ?? const [];

    return {
      for (final item in genres)
        if (item is Map<String, dynamic> &&
            item['id'] is num &&
            item['name'] is String)
          (item['id'] as num).toInt():
              item['name'] as String,
    };
  }

  List<Review> _parseReviews(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return const [];
    }

    final results =
        value['results'] as List<dynamic>? ?? const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .where((review) => review.content.trim().isNotEmpty)
        .take(10)
        .toList(growable: false);
  }

  List<CastMember> _parseCast(
    dynamic value, {
    required bool isTv,
  }) {
    if (value is! Map<String, dynamic>) {
      return const [];
    }

    final cast =
        value['cast'] as List<dynamic>? ?? const [];

    return cast
        .whereType<Map<String, dynamic>>()
        .map((person) {
          String character =
              person['character'] as String? ?? '';

          /*
           * aggregate_credits de series guarda el personaje dentro
           * de la lista "roles".
           */
          if (isTv && character.isEmpty) {
            final roles = person['roles'];

            if (roles is List && roles.isNotEmpty) {
              final firstRole = roles.first;

              if (firstRole is Map<String, dynamic>) {
                character =
                    firstRole['character'] as String? ?? '';
              }
            }
          }

          return CastMember(
            id: (person['id'] as num?)?.toInt() ?? 0,
            name: person['name'] as String? ?? '',
            character: character,
            profilePath:
                person['profile_path'] as String? ?? '',
          );
        })
        .where((person) => person.name.trim().isNotEmpty)
        .take(15)
        .toList(growable: false);
  }

  String _selectTrailerKey(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return '';
    }

    final videos =
        value['results'] as List<dynamic>? ?? const [];

    final youtubeVideos = videos
        .whereType<Map<String, dynamic>>()
        .where(
          (video) =>
              video['site'] == 'YouTube' &&
              video['key'] is String &&
              (video['key'] as String).isNotEmpty,
        )
        .toList();

    if (youtubeVideos.isEmpty) {
      return '';
    }

    Map<String, dynamic>? selected;

    for (final video in youtubeVideos) {
      if (video['type'] == 'Trailer' &&
          video['official'] == true) {
        selected = video;
        break;
      }
    }

    selected ??= youtubeVideos.cast<Map<String, dynamic>?>().firstWhere(
          (video) => video?['type'] == 'Trailer',
          orElse: () => null,
        );

    selected ??= youtubeVideos.cast<Map<String, dynamic>?>().firstWhere(
          (video) => video?['type'] == 'Teaser',
          orElse: () => null,
        );

    selected ??= youtubeVideos.first;

    return selected['key'] as String? ?? '';
  }

  List<String> _parseGenreNames(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((genre) => genre['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  List<int> _parseGenreIds(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((genre) => (genre['id'] as num?)?.toInt())
        .whereType<int>()
        .toList(growable: false);
  }

  int? _parseRuntime(
    Map<String, dynamic> data, {
    required bool isTv,
  }) {
    if (!isTv) {
      return (data['runtime'] as num?)?.toInt();
    }

    final episodeRunTime = data['episode_run_time'];

    if (episodeRunTime is List &&
        episodeRunTime.isNotEmpty &&
        episodeRunTime.first is num) {
      return (episodeRunTime.first as num).toInt();
    }

    final lastEpisode = data['last_episode_to_air'];

    if (lastEpisode is Map<String, dynamic>) {
      return (lastEpisode['runtime'] as num?)?.toInt();
    }

    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  String _textOrFallback(
    String? value,
    String fallback,
  ) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }
}