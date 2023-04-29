import 'dart:developer' as devtools show log;

import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:first_flutter_app/enums/menu_action.dart';
import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/services/crud/notes_service.dart';
import 'package:first_flutter_app/utilities/dialogs/logout_dialog.dart';
import 'package:first_flutter_app/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add note',
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              devtools.log('Clicked option: $value');
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log('Should logout: $shouldLogout');
                  if (shouldLogout) {
                    await AuthService.firebase().logOut().then((value) => {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false)
                        });
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Log out')),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                              allNotes: allNotes, notesService: _notesService);
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  });
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
