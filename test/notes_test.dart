
import 'package:first_flutter_app/services/crud/notes_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

void main(){
 group('CRUD service tests', () {

 });
}


class MockNotesService implements NotesService {
  Database? _db;

  DatabaseUser? _user;

  List<DatabaseNote> _notes = [];

  @override
  // TODO: implement allNotes
  Stream<List<DatabaseNote>> get allNotes => throw UnimplementedError();

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<DatabaseNote> createNote({required DatabaseUser owner}) {
    // TODO: implement createNote
    throw UnimplementedError();
  }

  @override
  Future<DatabaseUser> createUser({required String email}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<int> deleteAllNotes() {
    // TODO: implement deleteAllNotes
    throw UnimplementedError();
  }

  @override
  Future<void> deleteNote({required int id}) {
    // TODO: implement deleteNote
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser({required String email}) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<Iterable<DatabaseNote>> getAllNotes() {
    // TODO: implement getAllNotes
    throw UnimplementedError();
  }

  @override
  Future<DatabaseNote> getNote({required int id}) {
    // TODO: implement getNote
    throw UnimplementedError();
  }

  @override
  Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) {
    // TODO: implement getOrCreateUser
    throw UnimplementedError();
  }

  @override
  Future<DatabaseUser> getUser({required String email}) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) {
    // TODO: implement updateNote
    throw UnimplementedError();
  }

}