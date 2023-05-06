import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_flutter_app/services/cloud/cloud_note.dart';
import 'package:first_flutter_app/services/cloud/cloud_storage_constants.dart';
import 'package:first_flutter_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection(notesCollectionName);

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => notes
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .snapshots()
      .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
      titleFieldName: '',
    });

    final fetchedNote = await document.get();
    return CloudNote(
        documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '', title: '');
  }

  Future<void> updateNote(
      {required String documentId, required String text, required String title}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text, titleFieldName: title});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
