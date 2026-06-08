import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../entities/movie.dart';
import '../data/models/movie_model.dart';
import 'movies_datasources.dart';

class MoviesRemoteDatasource implements MoviesDatasource{
  final String _baseUrl = dotenv.env['TMDB_BASE_URL']!;
  final String _token = dotenv.env['TMDB_ACCESS_TOKEN']!;

  Map<String, String> get _headers =>{
    'Authorization': 'Bearer $_token',
    'accept' : 'application/json'
  };

  @override
  Future<List<Movie>> getNowPlaying() async {
    final url = Uri.parse('$_baseUrl/movie/now_playing?language=es-MX&page=1');

    final response = await http.get(url, headers: _headers);

    if(response.statusCode != 200){
      throw Exception('Error al cargar película (${response.statusCode})');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>;

    return results.map((item) => MovieModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}