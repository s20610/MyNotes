import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/views/login_view.dart';
import 'package:first_flutter_app/views/notes/new_note_view.dart';
import 'package:first_flutter_app/views/notes/notes_view.dart';
import 'package:first_flutter_app/views/register_view.dart';
import 'package:first_flutter_app/views/verify_email_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      newNoteRoute: (context) => const NewNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = AuthService.firebase().currentUser;
                if (user != null) {
                  if (user.isEmailVerified) {
                    return const NotesView();
                  } else {
                    return const VerifyEmailView();
                  }
                } else {
                  return const LoginView();
                }
                return const Text('Done');
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
