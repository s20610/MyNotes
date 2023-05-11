import 'package:first_flutter_app/services/auth/auth_exceptions.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/utilities/dialogs/error_dialog.dart';
import 'package:first_flutter_app/utilities/responsive/responsive_layout.dart';
import 'package:first_flutter_app/utilities/styles/widget_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener, ReadContext;

import '../../services/auth/bloc/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool passwordVisible = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    passwordVisible = true;
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget mobileView(){
    return Column(
      children: [
         SizedBox(
          height: MediaQuery.of(context).size.width/5,
        ),
        const Text(
          'Please log in to your account in order to interact with and create notes!',
          style: textStyleBig,
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              icon: Icon(Icons.email_outlined),
              hintText: 'Enter your email here',
              border: OutlineInputBorder()),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _password,
          obscureText: passwordVisible,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
              icon: const Icon(Icons.password_outlined),
              hintText: 'Enter your password here',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(passwordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(
                        () {
                      passwordVisible = !passwordVisible;
                    },
                  );
                },
              )),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: buttonStyle,
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context
                    .read<AuthBloc>()
                    .add(AuthEventLogIn(email, password));
              },
              child: const Text('Login'),
            ),
            const SizedBox(
              width: 20.0,
            ),
            ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventForgotPassword());
                },
                child: const Text('I forgot my password')),
          ],
        ),
        TextButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventShouldRegister());
            },
            child: const Text('Not registered yet? Register here!')),
      ],
    );
  }

  Widget desktopView(){
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width/1.75,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Please log in to your account in order to interact with and create notes!',
              style: textStyleTabletBig,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  icon: Icon(Icons.email_outlined),
                  hintText: 'Enter your email here',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _password,
              obscureText: passwordVisible,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                  icon: const Icon(Icons.password_outlined),
                  hintText: 'Enter your password here',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                            () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventLogIn(email, password));
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventForgotPassword());
                    },
                    child: const Text('I forgot my password')),
              ],
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: textStyleBig
              ),
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventShouldRegister());
                },
                child: const Text('Not registered yet? Click me!')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'Cannot find a user with the entered credentials!');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Log in'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResponsiveLayout(mobileWidget: mobileView(), tabletWidget: desktopView(),),
            ),
          )),
    );
  }
}
