import 'dart:async';

import 'package:first_flutter_app/extensions/list/filter.dart';
import 'package:first_flutter_app/services/crud/crud_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  DatabaseUser? _user;

  List<DatabaseNote> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();

  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note) {
    final currentUser = _user;
    if( currentUser != null){
      return note.userId == currentUser.id;
    }else{
      throw UserShouldBeSetBeforeReadingAllNotes();
    }
  });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
    });
    final note = DatabaseNote(id: noteId, userId: owner.id, text: text);

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final affectedRecords = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return affectedRecords;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) {
      throw NoteDoesNotExists();
    } else {
      final databaseNote = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(databaseNote);
      _notesStreamController.add(_notes);
      return databaseNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final iterable = notes.map((notesRow) => DatabaseNote.fromRow(notesRow));
    _notes = iterable.toList();
    _notesStreamController.add(_notes);
    return iterable;
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //make sure note exists
    await getNote(id: note.id);
    final updatesCount = await db.update(noteTable, {textColumn: text},
        where: 'id = ?', whereArgs: [note.id]);
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<DatabaseUser> getOrCreateUser(
      {required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserDoesNotExists {
      final databaseUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = databaseUser;
      }
      return databaseUser;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw UserDoesNotExists();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final userId = await db.insert(userTable, {emailColumn: email});
      return DatabaseUser(id: userId, email: email);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;

  DatabaseNote({required this.id, required this.userId, required this.text});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, text = ${text.substring(0, 2)}';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';

const createUserTable = '''
      create table if not exists user (
    id    integer not null
        constraint user_pk
            primary key autoincrement,
    email TEXT    not null
        constraint email_key
            unique
);
      ''';

const createNoteTable = '''
      create table if not exists note (
    id      integer not null
        constraint note_pk
            primary key autoincrement,
    user_id integer not null
        constraint note_user_id_fk
            references user,
    text    TEXT
);
      ''';
