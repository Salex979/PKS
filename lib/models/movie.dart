import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String? description;
  final int? year;
  final double? rating;
  final String? imageUrl;
  final bool isWatched;
  final DateTime addedDate;
  final String userId;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.year,
    this.rating,
    this.imageUrl,
    required this.isWatched,
    required this.addedDate,
    required this.userId,
  });

  // Конвертация в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'year': year,
      'rating': rating,
      'imageUrl': imageUrl,
      'isWatched': isWatched,
      'addedDate': Timestamp.fromDate(addedDate),
      'userId': userId,
    };
  }

  // Создание Movie из Firestore документа
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      year: data['year'],
      rating: (data['rating'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'],
      isWatched: data['isWatched'] ?? false,
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  // Копирование с изменениями
  Movie copyWith({
    String? id,
    String? title,
    String? description,
    int? year,
    double? rating,
    String? imageUrl,
    bool? isWatched,
    DateTime? addedDate,
    String? userId,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isWatched: isWatched ?? this.isWatched,
      addedDate: addedDate ?? this.addedDate,
      userId: userId ?? this.userId,
    );
  }
}