import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Коллекция фильмов пользователя
  CollectionReference<Map<String, dynamic>> _moviesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('movies');
  }

  // Получить все фильмы пользователя (Stream для реального обновления)
  Stream<List<Movie>> getMoviesStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return _moviesCollection(userId)
        .orderBy('addedDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList());
  }

  // Добавить фильм
  Future<void> addMovie(String userId, Movie movie) async {
    if (userId.isEmpty) return;
    
    await _moviesCollection(userId).doc(movie.id).set(movie.toMap());
  }

  // Обновить фильм
  Future<void> updateMovie(String userId, Movie movie) async {
    if (userId.isEmpty) return;
    
    await _moviesCollection(userId).doc(movie.id).update(movie.toMap());
  }

  // Удалить фильм
  Future<void> deleteMovie(String userId, String movieId) async {
    if (userId.isEmpty) return;
    
    await _moviesCollection(userId).doc(movieId).delete();
  }

  // Поиск фильмов
  Stream<List<Movie>> searchMovies(String userId, String query) {
    if (userId.isEmpty) return Stream.value([]);
    
    if (query.isEmpty) {
      return getMoviesStream(userId);
    }

    return _moviesCollection(userId)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList());
  }
}