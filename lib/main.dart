import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:first_flutter_app/helpers/loading/loading_screen.dart';
import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_state.dart';
import 'package:first_flutter_app/views/forgot_password_view.dart';
import 'package:first_flutter_app/views/login_view.dart';
import 'package:first_flutter_app/views/notes/create_update_note_view.dart';
import 'package:first_flutter_app/views/notes/notes_view.dart';
import 'package:first_flutter_app/views/register_view.dart';
import 'package:first_flutter_app/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.green, useMaterial3: false),
    darkTheme: ThemeData.dark(
      useMaterial3: false,
    ),
    home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(AuthService.firebase()),
        child: const HomePage()),
    routes: {
      createUpdateNoteView: (context) => const CreateUpdateNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment');
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
