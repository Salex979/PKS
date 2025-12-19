import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/auth_service.dart';
import '../widgets/movie_card.dart';
import 'add_edit_movie_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (currentUser != null && currentUser.id.isNotEmpty) {
      movieProvider.setUserId(currentUser.id);
    }
  });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои фильмы'),
        actions: [
          // Фильтр просмотренных
          IconButton(
            icon: Icon(movieProvider.showWatchedOnly
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () => movieProvider.toggleWatchedFilter(),
            tooltip: movieProvider.showWatchedOnly
                ? 'Показать все'
                : 'Только просмотренные',
          ),
          
          // Меню пользователя
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context, authService);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(currentUser?.displayName ?? 'Профиль'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Выйти', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск фильмов...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          movieProvider.searchMovies('');
                        },
                      )
                    : null,
              ),
              onChanged: movieProvider.searchMovies,
            ),
          ),
          
          // Список фильмов
          Expanded(
            child: movieProvider.movies.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Фильмов пока нет\nДобавьте первый!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: movieProvider.movies.length,
                    itemBuilder: (context, index) {
                      final movie = movieProvider.movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () => _showMovieDetails(context, movie),
                        onEdit: () => _navigateToEditScreen(context, movieProvider.movies[index]),
                        onDelete: () => _showDeleteDialog(context, movieProvider, movie),
                        onToggleWatched: () => _toggleWatchedStatus(context, movieProvider.movies[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditMovieScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMovieDetails(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(movie.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (movie.imageUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(movie.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Информация о фильме
              if (movie.year != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Год: ${movie.year}'),
                    ],
                  ),
                ),
              
              if (movie.rating != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('Оценка: ${movie.rating}/5'),
                    ],
                  ),
                ),
              
              // Статус
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        movie.isWatched ? 'Просмотрено' : 'К просмотру',
                        style: TextStyle(
                          color: movie.isWatched ? Colors.green : Colors.blue,
                        ),
                      ),
                      backgroundColor: movie.isWatched ? Colors.green[100] : Colors.blue[100],
                    ),
                  ],
                ),
              ),
              
              // Описание
              if (movie.description != null && movie.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Отзыв:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          // Кнопка закрыть
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          
          // Кнопка редактировать
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 1. Закрыть диалог
              _navigateToEditScreen(context, movie); // 2. Открыть экран редактирования
            },
            child: const Text(
              'Редактировать',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Кнопка переключить статус (опционально)
          TextButton(
            onPressed: () {
              _toggleWatchedStatus(context, movie);
              Navigator.pop(context);
            },
            child: Text(
              movie.isWatched ? 'Не просмотрено' : 'Просмотрено',
              style: TextStyle(
                color: movie.isWatched ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWatchedStatus(BuildContext context, Movie movie) {
    final movieProvider = context.read<MovieProvider>();
    final updatedMovie = movie.copyWith(isWatched: !movie.isWatched);
    movieProvider.updateMovie(updatedMovie);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedMovie.isWatched 
            ? 'Отмечено как просмотренное: ${movie.title}' 
            : 'Снята отметка просмотренного: ${movie.title}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMovieScreen(movie: movie),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MovieProvider movieProvider, Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              movieProvider.deleteMovie(movie.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Фильм "${movie.title}" удален'),
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.logout();
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}