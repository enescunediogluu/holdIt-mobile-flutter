import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holdit/components/square_tile.dart';
import 'package:holdit/services/auth/auth_exceptions.dart';
import 'package:holdit/services/auth/bloc/auth_bloc.dart';
import 'package:holdit/services/auth/bloc/auth_event.dart';
import 'package:holdit/services/auth/bloc/auth_state.dart';
import 'package:holdit/utilities/dialogs/loading_dialog.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'This user is not exist. Please try again!');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context, 'The password is wrong. Please try again!');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 112),
                  Text(
                    'HOLD IT',
                    style: TextStyle(
                      color: Colors.grey[440],
                      fontFamily: 'HeaderFont',
                      fontSize: 75,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Icon(
                    Icons.lock,
                    color: Colors.deepPurple,
                    size: 75,
                  ),
                  const SizedBox(height: 30),
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
                              color: Colors.grey[350], fontFamily: 'MainFont'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2.5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200),
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
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
                              color: Colors.grey[350], fontFamily: 'MainFont'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2.5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200),
                      obscureText: _obscureText,
                      enableSuggestions: false,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      context.read<AuthBloc>().add(AuthEventLogIn(
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
                      'Sign In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'MainFont'),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with ',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontFamily: 'MainFont'),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(imagePath: 'lib/images/google.png'),
                      SizedBox(width: 10),
                      SquareTile(imagePath: 'lib/images/apple.png'),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Not a member?',
                        style: TextStyle(fontFamily: 'MainFont'),
                      ),
                      TextButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventShouldRegister());
                          },
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                                color: Colors.blue, fontFamily: 'MainFont'),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
