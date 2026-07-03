import 'package:flutter/foundation.dart';

import 'package:chipileta_movies_app/domain/entities/movie.dart';

class MovieListsController extends ChangeNotifier {
  final List<Movie> _favorites = [];
  final List<Movie> _saved = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);
  List<Movie> get saved => List.unmodifiable(_saved);

  bool isFavorite(Movie movie) {
    return _favorites.any((item) => item.id == movie.id);
  }

  bool isSaved(Movie movie) {
    return _saved.any((item) => item.id == movie.id);
  }

  void toggleFavorite(Movie movie) {
    if (isFavorite(movie)) {
      _favorites.removeWhere((item) => item.id == movie.id);
    } else {
      _favorites.add(movie);
    }

    notifyListeners();
  }

  void toggleSaved(Movie movie) {
    if (isSaved(movie)) {
      _saved.removeWhere((item) => item.id == movie.id);
    } else {
      _saved.add(movie);
    }

    notifyListeners();
  }

  void removeFavorite(Movie movie) {
    _favorites.removeWhere((item) => item.id == movie.id);
    notifyListeners();
  }

  void removeSaved(Movie movie) {
    _saved.removeWhere((item) => item.id == movie.id);
    notifyListeners();
  }
}

final movieListsController = MovieListsController();