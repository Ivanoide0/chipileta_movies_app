import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:chipileta_movies_app/domain/entities/movie.dart';

class MovieListsController extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  MovieListsController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String? _uid;
  final List<Movie> _favorites = [];
  final List<Movie> _saved = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);
  List<Movie> get saved => List.unmodifiable(_saved);

  CollectionReference<Map<String, dynamic>> _col(String list) =>
      _firestore.collection('users').doc(_uid).collection(list);

  bool isFavorite(Movie movie) =>
      _favorites.any((item) => item.storageKey == movie.storageKey);

  bool isSaved(Movie movie) =>
      _saved.any((item) => item.storageKey == movie.storageKey);

  Future<void> loadForUser(String uid) async {
    _uid = uid;
    _favorites.clear();
    _saved.clear();
    notifyListeners();

    final results = await Future.wait([
      _col('favorites').get(),
      _col('saved').get(),
    ]);

    if (_uid != uid) return;

    _favorites.addAll(results[0].docs.map((d) => _movieFromMap(d.data())));
    _saved.addAll(results[1].docs.map((d) => _movieFromMap(d.data())));
    notifyListeners();
  }

  void clear() {
    _uid = null;
    _favorites.clear();
    _saved.clear();
    notifyListeners();
  }

  void toggleFavorite(Movie movie) => _toggle(_favorites, 'favorites', movie);
  void toggleSaved(Movie movie) => _toggle(_saved, 'saved', movie);
  void removeFavorite(Movie movie) => _remove(_favorites, 'favorites', movie);
  void removeSaved(Movie movie) => _remove(_saved, 'saved', movie);

  void _toggle(List<Movie> list, String col, Movie movie) {
    if (list.any((m) => m.storageKey == movie.storageKey)) {
      _remove(list, col, movie);
    } else {
      list.add(movie);
      notifyListeners();
      if (_uid != null) {
        unawaited(
          _col(col).doc(movie.storageKey).set(_movieToMap(movie)).catchError((_) {}),
        );
      }
    }
  }

  void _remove(List<Movie> list, String col, Movie movie) {
    list.removeWhere((m) => m.storageKey == movie.storageKey);
    notifyListeners();
    if (_uid != null) {
      unawaited(_col(col).doc(movie.storageKey).delete().catchError((_) {}));
    }
  }

  Map<String, dynamic> _movieToMap(Movie m) => {
        'id': m.id,
        'media_type': m.mediaType,
        'title': m.title,
        'overview': m.overview,
        'poster_path': m.posterPath,
        'backdrop_path': m.backdropPath,
        'vote_average': m.voteAverage,
        'release_date': m.releaseDate?.toIso8601String(),
        'genre_ids': m.genreIds,
        'saved_at': FieldValue.serverTimestamp(),
      };

  Movie _movieFromMap(Map<String, dynamic> map) => Movie(
        id: (map['id'] as num).toInt(),
        mediaType: (map['media_type'] as String?) ?? 'movie',
        title: (map['title'] as String?) ?? '',
        overview: (map['overview'] as String?) ?? '',
        posterPath: (map['poster_path'] as String?) ?? '',
        backdropPath: (map['backdrop_path'] as String?) ?? '',
        voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
        releaseDate: map['release_date'] is String
            ? DateTime.tryParse(map['release_date'] as String)
            : null,
        genreIds: (map['genre_ids'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [],
      );
}

final movieListsController = MovieListsController();
