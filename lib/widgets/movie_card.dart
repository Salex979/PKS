import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onEdit; 
  final VoidCallback onDelete;
  final VoidCallback onToggleWatched;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleWatched,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Постер фильма
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: movie.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(movie.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: movie.imageUrl == null
                    ? const Icon(Icons.movie, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Информация о фильме
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и статус
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (movie.isWatched)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                      ],
                    ),
                    
                    // Год и рейтинг
                    if (movie.year != null || movie.rating != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            if (movie.year != null)
                              Text(
                                '${movie.year}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            if (movie.year != null && movie.rating != null)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('•'),
                              ),
                            if (movie.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text('${movie.rating!.toStringAsFixed(1)}'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    
                    // Описание
                    if (movie.description != null && movie.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          movie.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Кнопка удаления
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}