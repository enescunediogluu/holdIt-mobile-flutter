import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:holdit/constants/routes.dart';
import 'package:holdit/firebase_options.dart';
import 'package:holdit/services/auth/auth_service.dart';
import 'package:holdit/wiews/loading_screen.dart';
import 'package:holdit/wiews/login_view.dart';
import 'package:holdit/wiews/notes/new_note_view.dart';
import 'package:holdit/wiews/notes/notes_view.dart';
import 'package:holdit/wiews/register_view.dart';
import 'package:holdit/wiews/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hold It!',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NoteView(),
      verifyRoute: (context) => const VerifyEmailView(),
      modernNotesRoute: (context) => const NoteView(),
      newNoteRoute: (context) => const NewNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const LoginView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const LoadingScreen();
        }
      },
    );
  }
}
