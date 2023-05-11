import 'package:first_flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_state.dart';
import 'package:first_flutter_app/utilities/dialogs/error_dialog.dart';
import 'package:first_flutter_app/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:first_flutter_app/utilities/styles/widget_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear;
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(context,
                'We could not process your request. Pleas make sure that you are a registered user');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40,),
                const Text(
                    'If you forgot your password, simply enter your email and we will send you a password reset link', style: textStyleBig,),
                const SizedBox(height: 15,),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: false,
                  controller: _controller,
                  decoration:
                      const InputDecoration(icon: Icon(Icons.email_outlined), border: OutlineInputBorder(),
                          hintText: 'Your email address...'),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send me a password reset link'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text('Back to login page'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
