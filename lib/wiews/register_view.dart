import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holdit/services/auth/auth_exceptions.dart';
import 'package:holdit/services/auth/bloc/auth_bloc.dart';
import 'package:holdit/services/auth/bloc/auth_event.dart';
import 'package:holdit/services/auth/bloc/auth_state.dart';

import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscureText = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email already in use!');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email address!');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Register failed!');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Image.asset(
                  'lib/images/register_icon.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(
                  height: 35,
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.grey.withOpacity(1.0),
                                BlendMode.srcATop),
                            child: Image.asset(
                              'lib/images/email_icon.png',
                              width: 10,
                            ),
                          ),
                        ),
                        hintText: 'Please enter your email here',
                        hintStyle: TextStyle(
                          color: Colors.grey[350],
                          fontFamily: 'MainFont',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(220, 220, 172, 12),
                              width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200),
                    obscureText: false,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _password,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'lib/images/password_icon.png',
                            width: 10,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: null,
                          ),
                        ),
                        hintText: 'Please enter your password here',
                        hintStyle: TextStyle(
                          color: Colors.grey[350],
                          fontFamily: 'MainFont',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(220, 220, 172, 12),
                              width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200),
                    obscureText: _obscureText,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;

                    context.read<AuthBloc>().add(AuthEventRegister(
                          email,
                          password,
                        ));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 135),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'MainFont',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'You already have an account?',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'MainFont',
                  ),
                ),
                TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text('Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontFamily: 'MainFont',
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
