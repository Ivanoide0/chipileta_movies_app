import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/get_now_playing_usecase.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetNowPlayingUseCase _getNowPlaying;
  late final Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    final datasource = MoviesRemoteDatasource();
    final repository = MoviesRepositoryImpl(datasource);
    _getNowPlaying = GetNowPlayingUseCase(repository);
    _moviesFuture = _getNowPlaying();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('En cartelera')),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const Center(child: Text('No hay películas.'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: movie.posterPath.isEmpty
                    ? const Icon(Icons.movie)
                    : Image.network(
                        'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                title: Text(movie.title),
                subtitle: Text(
                  movie.releaseDate?.year.toString() ?? 'Sin fecha',
                ),
                trailing: Text('⭐ ${movie.voteAverage.toStringAsFixed(1)}'),
              );
            },
          );
        },
      ),
    );
  }
}