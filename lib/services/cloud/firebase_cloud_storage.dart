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

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote.fromSnapshot(doc);
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
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
