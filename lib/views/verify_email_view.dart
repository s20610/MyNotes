import 'dart:developer' as devtools show log;

import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:first_flutter_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

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
      body: Center(
        child: Column(
          children: [
            const Text("We've already sent a verification email!"),
            const Text(
                "If you haven't received a verification email yet, press the button below"),
            TextButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                child: const Text('Send email verification')),
            TextButton(
                onPressed: () async {
                  devtools.log(user?.isEmailVerified.toString() ?? 'null');
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                },
                child: const Text('Already verified? Click me'))
          ],
        ),
      ),
    );
  }
}
