import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/models/movie_model.dart';
import '../entities/movie.dart';
import 'movies_datasources.dart';
import '../data/models/review_model.dart';
import '../entities/review.dart';

class MoviesRemoteDatasource implements MoviesDatasource {
  final String _baseUrl = dotenv.env['TMDB_BASE_URL']!;
  final String _token = dotenv.env['TMDB_ACCESS_TOKEN']!;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'accept': 'application/json',
      };

  // Método existente: conserva el mismo endpoint y comportamiento.
  @override
  Future<List<Movie>> getNowPlaying() async {
    final url = Uri.parse(
      '$_baseUrl/movie/now_playing?language=es-MX&page=1',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar película (${response.statusCode})',
      );
    }

    final decoded =
        json.decode(response.body) as Map<String, dynamic>;

    final results = decoded['results'] as List<dynamic>;

    return results
        .map(
          (item) => MovieModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Métodos nuevos para la pantalla Home.

  @override
  Future<List<Movie>> getPopularMovies() {
    return _getMovies('/movie/popular');
  }

  @override
  Future<List<Movie>> getPopularSeries() {
    return _getMovies('/tv/popular');
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
    final url = Uri.parse('$_baseUrl/movie/$movieId/reviews').replace(
      queryParameters: const {
        'language': 'en-US',
        'page': '1',
      },
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar reseñas (${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? const [];

    return results
      .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
      .toList();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async{
    final trimmed = query.trim();
    if(trimmed.isEmpty) return const [];

    final url = Uri.parse('$_baseUrl/search/movie').replace(
      queryParameters: {
        'language': 'es-MX',
        'page': '1',
        'include_adult': 'false',
        'query': trimmed
      }
    );

    final response = await http.get(url, headers: _headers);

    if(response.statusCode != 200){
      throw Exception(
        'Error al buscar películas (${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? const [];

  return results.map((item) => MovieModel.fromJson(item as Map<String, dynamic>)).toList();
}

  Future<List<Movie>> _getMovies(String path) async {
    final url = Uri.parse('$_baseUrl$path').replace(
      queryParameters: const {
        'language': 'es-MX',
        'page': '1',
      },
    );

    final response = await http.get(url, headers: _headers);

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
        .map(
          (item) => MovieModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Map<int, String>> _getGenres(String path) async {
    final url = Uri.parse('$_baseUrl$path').replace(
      queryParameters: const {
        'language': 'es-MX',
      },
    );

    final response = await http.get(url, headers: _headers);

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
          (item['id'] as num).toInt(): item['name'] as String,
    };
  }
}