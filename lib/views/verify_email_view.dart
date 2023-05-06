import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/utilities/styles/widget_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/auth/bloc/auth_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40,),
            const Text("We've already sent a verification email!"),
            const SizedBox(height: 5,),
            const Text(
                "If you haven't received a verification email yet, press the button below"),
            const SizedBox(height: 15,),
            ElevatedButton(
              style: buttonStyle,
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventSendEmailVerification());
                },
                child: const Text('Send email verification')),
          ],
        ),
      ),
    );
  }
}
