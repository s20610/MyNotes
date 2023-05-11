import 'dart:developer' as devtools show log;

import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:first_flutter_app/enums/menu_action.dart';
import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/services/cloud/cloud_note.dart';
import 'package:first_flutter_app/services/cloud/firebase_cloud_storage.dart';
import 'package:first_flutter_app/utilities/dialogs/logout_dialog.dart';
import 'package:first_flutter_app/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _searchController;

  String get ownerUserId => AuthService.firebase().currentUser!.userId;

  Iterable<CloudNote> _notes = [];
  Iterable<CloudNote> _filteredNotes = [];

  Future<void> _performSearch() async {
    setState(() {
      _filteredNotes = _notes
          .where((note) => note.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _searchController = TextEditingController();
    _searchController.addListener(_performSearch);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
          // title: TextField(
          //   controller: _searchController,
          //   style: const TextStyle(color: Colors.white),
          //   cursorColor: Colors.white,
          //   decoration: const InputDecoration(
          //     hintText: 'Search...',
          //     hintStyle: TextStyle(color: Colors.white),
          //     border: InputBorder.none,
          //   ),
          // ),
          // leading: const Icon(
          //   Icons.search,
          //   color: Colors.white,
          // ),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                devtools.log('Clicked option: $value');
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    devtools.log('Should logout: $shouldLogout');
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Row(
                        children: [
                          Text('Log out'),
                          SizedBox(width: 5),
                          Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                        ],
                      )),
                ];
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(createUpdateNoteView);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: ownerUserId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    _notes = snapshot.data as Iterable<CloudNote>;
                    // if (_filteredNotes.isEmpty) {
                    //   _filteredNotes = _notes;
                    // }
                    return NotesListView(
                      allNotes: _notes,
                      notesService: _notesService,
                      onTap: (note) {
                        Navigator.of(context)
                            .pushNamed(createUpdateNoteView, arguments: note);
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
