import 'package:first_flutter_app/services/cloud/cloud_note.dart';
import 'package:first_flutter_app/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> allNotes;
  final FirebaseCloudStorage notesService;
  final NoteCallback onTap;

  const NotesListView(
      {Key? key,
      required this.allNotes,
      required this.notesService,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, index) {
          final note = allNotes.elementAt(index);
          final noteTitle = note.title;
          return Column(
            children: [
              Dismissible(
                key: Key(noteTitle),
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
                  await notesService
                      .deleteNote(documentId: note.documentId)
                      .then((_) => {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note deleted')))
                          });
                },
                child: ListTile(
                  onTap: () {
                    onTap(note);
                  },
                  title: Text(
                    noteTitle,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              )
            ],
          );
        });
  }
}
