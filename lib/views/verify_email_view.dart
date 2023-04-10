import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_flutter_app/constants/route_strings.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("We've already sent a verification email!"),
            const Text("If you haven't received a verification email yet, press the button below"),
            TextButton(
                onPressed: () async {
                  await user?.sendEmailVerification();
                },
                child: const Text('Send email verification')),
            TextButton(
                onPressed: () async {
                  await user?.reload();
                  devtools.log(user?.emailVerified.toString() ?? 'null');
                  if (user?.emailVerified ?? false) {
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
