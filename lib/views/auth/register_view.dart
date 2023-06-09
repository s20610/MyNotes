import 'package:first_flutter_app/services/auth/auth_exceptions.dart';
import 'package:first_flutter_app/services/auth/bloc/auth_event.dart';
import 'package:first_flutter_app/utilities/dialogs/error_dialog.dart';
import 'package:first_flutter_app/utilities/responsive/responsive_layout.dart';
import 'package:first_flutter_app/utilities/styles/widget_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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

  Widget mobileView() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        const Text(
          'Please input your email and chosen password to create an account',
          style: textStyleBig,
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(
              icon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              hintText: 'Enter your email here'),
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
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
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
        ElevatedButton(
          style: buttonStyle,
          onPressed: () async {
            final email = _email.text;
            final password = _password.text;

            context.read<AuthBloc>().add(AuthEventRegister(email, password));
          },
          child: const Text('Register'),
        ),
        TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text('Already have an account? Log in!'))
      ],
    );
  }

  Widget desktopView() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.75,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Please input your email and chosen password to create an account',
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
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email here'),
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
            ElevatedButton(
              style: buttonStyle,
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                context
                    .read<AuthBloc>()
                    .add(AuthEventRegister(email, password));
              },
              child: const Text('Register'),
            ),
            TextButton(
                style: TextButton.styleFrom(textStyle: textStyleBig),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Already have an account? Log in!'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          final exception = state.exception;
          if (exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak password');
          } else if (exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use');
          } else if (exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          } else if (exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email');
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResponsiveLayout(
                  mobileWidget: mobileView(), tabletWidget: desktopView()),
            ),
          )),
    );
  }

  static const snackBar = SnackBar(
    content: Text('Account successfully created'),
  );
}
