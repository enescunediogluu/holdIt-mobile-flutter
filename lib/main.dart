import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holdit/constants/routes.dart';
import 'package:holdit/helpers/loading/loading_screen.dart';
import 'package:holdit/services/auth/bloc/auth_bloc.dart';
import 'package:holdit/services/auth/bloc/auth_event.dart';
import 'package:holdit/services/auth/bloc/auth_state.dart';
import 'package:holdit/services/auth/firebase_auth_provider.dart';
import 'package:holdit/wiews/login_view.dart';
import 'package:holdit/wiews/notes/create_update_note_view.dart';
import 'package:holdit/wiews/notes/notes_view.dart';
import 'package:holdit/wiews/register_view.dart';
import 'package:holdit/wiews/todos/create_update_todo_view.dart';
import 'package:holdit/wiews/todos/todos_view.dart';
import 'package:holdit/wiews/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hold It!',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      registerRoute: (context) => const RegisterView(),
      todoListRoute: (context) => const TodoView(),
      createUpdateTodoRoute: (context) => const CreateUpdateTodoView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment!',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NoteView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateOnNotesView) {
          return const NoteView();
        } else if (state is AuthStateOnTodosView) {
          return const TodoView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
