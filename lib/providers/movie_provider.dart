import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';

class MovieProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Movie> _movies = [];
  bool _showWatchedOnly = false;
  String _searchQuery = '';
  String? _userId;

  MovieProvider(this._firestoreService);

  List<Movie> get movies {
    var result = _movies;
    
    // Фильтр по просмотренным
    if (_showWatchedOnly) {
      result = result.where((movie) => movie.isWatched).toList();
    }
    
    // Поиск
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((movie) {
        return movie.title.toLowerCase().contains(query) ||
            (movie.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return result;
  }

  bool get showWatchedOnly => _showWatchedOnly;
  String get searchQuery => _searchQuery;

  // Установить userId и начать слушать фильмы
  void setUserId(String userId) {
    _userId = userId;
    if (userId.isNotEmpty) {
      _firestoreService.getMoviesStream(userId).listen((movies) {
        _movies = movies;
        notifyListeners();
      });
    }
  }

  // Добавить фильм
  Future<void> addMovie(Movie movie) async {
    if (_userId == null || _userId!.isEmpty) return;
    await _firestoreService.addMovie(_userId!, movie);
  }

  // Обновить фильм
  Future<void> updateMovie(Movie movie) async {
    if (_userId == null || _userId!.isEmpty) return;
    await _firestoreService.updateMovie(_userId!, movie);
  }

  // Удалить фильм
  Future<void> deleteMovie(String movieId) async {
    if (_userId == null || _userId!.isEmpty) return;
    await _firestoreService.deleteMovie(_userId!, movieId);
  }

  // Переключить фильтр просмотренных
  void toggleWatchedFilter() {
    _showWatchedOnly = !_showWatchedOnly;
    notifyListeners();
  }

  // Поиск фильмов
  void searchMovies(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Очистить поиск
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}