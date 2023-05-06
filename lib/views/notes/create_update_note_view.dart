import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/services/cloud/cloud_note.dart';
import 'package:first_flutter_app/services/cloud/firebase_cloud_storage.dart';
import 'package:first_flutter_app/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:first_flutter_app/utilities/generics/get_arguments.dart';
import 'package:first_flutter_app/utilities/styles/widget_styles.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _noteTextController;
  late final TextEditingController _titleTextController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _noteTextController.text = widgetNote.text;
      _titleTextController.text = widgetNote.title;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final ownerUserId = currentUser.userId;
    final note = await _notesService.createNewNote(ownerUserId: ownerUserId);
    _note = note;
    return note;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_noteTextController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _titleTextController.text;
    final text = _noteTextController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(documentId: note.documentId, text: text, title: title);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleTextController.text;
    final text = _noteTextController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text, title: title);
  }

  void _setupTextControllerListener() {
    _noteTextController.removeListener(_textControllerListener);
    _noteTextController.addListener(_textControllerListener);
    _titleTextController.removeListener(_textControllerListener);
    _titleTextController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _noteTextController = TextEditingController();
    _titleTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _noteTextController.dispose();
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Note'),
          actions: [
            IconButton(onPressed: () async{
              final text = _noteTextController.text;
              if(_note == null || text.isEmpty){
                await showCannotShareEmptyNoteDialog(context);
              }else{
                Share.share(text);
              }
            }, icon: const Icon(Icons.share))
          ],
        ),
        body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Title', style: textStyleBig,),
                      const SizedBox(height: 5,),
                      TextField(
                        controller: _titleTextController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: const InputDecoration(border: OutlineInputBorder(),
                            hintText: 'Your note title'),
                      ),
                      const SizedBox(height: 10,),
                      const Text('Note content', style: textStyleBig,),
                      const SizedBox(height: 5,),
                      TextField(
                        controller: _noteTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(border: OutlineInputBorder(),
                            hintText: 'Start typing your note...'),
                      ),
                    ],
                  ),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
