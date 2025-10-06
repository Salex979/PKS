# Отчет по практическому заданию № 5
## Полякова София Александровна, ЭФБО-10-23

# Цели:
-	Научиться отображать коллекции данных с помощью ListView.builder.
-	Освоить базовую навигацию Navigator.push / Navigator.pop и передачу данных через конструктор.
-	Научиться добавлять, редактировать и удалять элементы списка без внешних пакетов и сложных архитектур.

# Контрольная точка 1
Список заметок

Отображает список заметок с помощью ListView.builder. Каждая заметка показывается в карточке с заголовком и текстом
``` dart
: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return Dismissible(
                            key: ValueKey(note.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteNote(note),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              color: const Color(0xFFE0DCEC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  note.title.isEmpty ? '(без названия)' : note.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: note.body.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          note.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF3C3C43),
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () => _editNote(note),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () => _deleteNote(note),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
```

<img width="405" height="862" alt="image" src="https://github.com/user-attachments/assets/205c3512-2e31-466b-9a07-de2dfc0d7d69">

# Контрольная точка 2
Добавление новой заметки

Открывает экран создания новой заметки
```
  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const EditNotePage()),
    );
    
    if (newNote != null && mounted) {
      setState(() => _notes.insert(0, newNote));
    }
  }
```

https://github.com/user-attachments/assets/6c40bfa9-d6b8-40b9-8483-b8c1080c8268

# Контрольная точка 3
Редактирование заметки

Открывает экран редактирования существующей заметки
```
Future<void> _editNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );
    
    if (updatedNote != null && mounted) {
      setState(() {
        final index = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
      });
    }
  }
```

https://github.com/user-attachments/assets/8e1f25f8-28b3-4737-9771-caed9a7b72e6

# Контрольная точка 4
Удаление заметки с помощью свапа

Позволяет удалить заметку свайпом влево
```
return Dismissible(
                            key: ValueKey(note.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteNote(note),
```

https://github.com/user-attachments/assets/e1389f8e-d6d5-426f-8880-213491882ec8

# Контрольная точка 5
Удаление заметки с помощью кнопки

Кнопка корзины в правом углу каждой заметки
```
void _deleteNote(Note note) {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
```

https://github.com/user-attachments/assets/9a2663bc-d0c0-4b31-80a8-c6d0f06884dc

Получилось сделать список заметок с помощью ListView.builder, а также научились добавлять, редактировать и удалять элементы списка без внешних пакетов.
