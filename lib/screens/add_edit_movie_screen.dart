import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/auth_service.dart';

class AddEditMovieScreen extends StatefulWidget {
  final Movie? movie;

  const AddEditMovieScreen({Key? key, this.movie}) : super(key: key);

  @override
  _AddEditMovieScreenState createState() => _AddEditMovieScreenState();
}

class _AddEditMovieScreenState extends State<AddEditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isWatched = false;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      if (widget.movie!.year != null) {
        _yearController.text = widget.movie!.year.toString();
      }
      if (widget.movie!.rating != null) {
        _ratingController.text = widget.movie!.rating.toString();
      }
      _descriptionController.text = widget.movie!.description ?? '';
      _imageUrlController.text = widget.movie!.imageUrl ?? '';
      _isWatched = widget.movie!.isWatched;
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.read<MovieProvider>();
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Добавить фильм' : 'Редактировать фильм'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Название фильма
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название фильма *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.movie),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название фильма';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Год выпуска
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Год выпуска',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: '2023',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Рейтинг
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Оценка (0-5)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                  hintText: '4.5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Ссылка на постер
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Ссылка на постер',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://example.com/poster.jpg',
                ),
              ),
              const SizedBox(height: 16),
              
              // Описание
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Отзыв',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Статус просмотра
              SwitchListTile(
                title: const Text('Просмотрено'),
                value: _isWatched,
                onChanged: (value) => setState(() => _isWatched = value),
              ),
              const SizedBox(height: 24),
              
              // Кнопка сохранения
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && currentUser != null) {
                    final movie = Movie(
                      id: widget.movie?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : null,
                      year: _yearController.text.isNotEmpty
                          ? int.tryParse(_yearController.text)
                          : null,
                      rating: _ratingController.text.isNotEmpty
                          ? double.tryParse(_ratingController.text)
                          : null,
                      imageUrl: _imageUrlController.text.isNotEmpty
                          ? _imageUrlController.text
                          : null,
                      isWatched: _isWatched,
                      addedDate: widget.movie?.addedDate ?? DateTime.now(),
                      userId: currentUser.id,
                    );

                    try {
                      if (widget.movie == null) {
                        await movieProvider.addMovie(movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Фильм добавлен!'),
                          ),
                        );
                      } else {
                        await movieProvider.updateMovie(movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Фильм обновлен!'),
                          ),
                        );
                      }
                      
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.movie == null ? 'Добавить фильм' : 'Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}