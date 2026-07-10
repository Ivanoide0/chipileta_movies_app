import 'package:flutter/foundation.dart';

import 'package:chipileta_movies_app/domain/entities/movie.dart';

class MovieListsController extends ChangeNotifier {
  final List<Movie> _favorites = [];
  final List<Movie> _saved = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);
  List<Movie> get saved => List.unmodifiable(_saved);

  bool isFavorite(Movie movie) {
    return _favorites.any(
      (item) => item.storageKey == movie.storageKey,
    );
  }

  bool isSaved(Movie movie) {
    return _saved.any(
      (item) => item.storageKey == movie.storageKey,
    );
  }

  void toggleFavorite(Movie movie) {
    if (isFavorite(movie)) {
      _favorites.removeWhere(
        (item) => item.storageKey == movie.storageKey,
      );
    } else {
      _favorites.add(movie);
    }

    notifyListeners();
  }

  void toggleSaved(Movie movie) {
    if (isSaved(movie)) {
      _saved.removeWhere(
        (item) => item.storageKey == movie.storageKey,
      );
    } else {
      _saved.add(movie);
    }

    notifyListeners();
  }

  void removeFavorite(Movie movie) {
    _favorites.removeWhere(
      (item) => item.storageKey == movie.storageKey,
    );

    notifyListeners();
  }

  void removeSaved(Movie movie) {
    _saved.removeWhere(
      (item) => item.storageKey == movie.storageKey,
    );

    notifyListeners();
  }
}

final movieListsController = MovieListsController();