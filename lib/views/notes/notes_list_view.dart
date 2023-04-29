import 'package:first_flutter_app/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> allNotes;
  final NotesService notesService;

  const NotesListView(
      {Key? key, required this.allNotes, required this.notesService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, index) {
          final note = allNotes.elementAt(index);
          final noteText = note.text;
          return Dismissible(
            key: Key(noteText),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
            ),
            onDismissed: (direction) async {
              await notesService.deleteNote(id: note.id).then((_) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Note deleted')))
                  });
            },
            child: ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              title: Text(
                noteText,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        });
  }
}
