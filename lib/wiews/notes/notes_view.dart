import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holdit/constants/routes.dart';
import 'package:holdit/enums/menu_action.dart';
import 'package:holdit/services/auth/auth_service.dart';
import 'package:holdit/services/auth/bloc/auth_bloc.dart';
import 'package:holdit/services/auth/bloc/auth_event.dart';
import 'package:holdit/services/cloud/cloud_note.dart';
import 'package:holdit/services/cloud/firebase_cloud_storage.dart';
import 'package:holdit/utilities/dialogs/logout_dialog.dart';
import 'package:holdit/wiews/notes/notes_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your Notes',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'MainFont',
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add, color: Colors.black, size: 35),
            ),
            PopupMenuButton<MenuAction>(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              elevation: 3,
              surfaceTintColor: Colors.black,
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 35,
              ),
              color: Colors.white,
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      // ignore: use_build_context_synchronously
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Center(
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          fontFamily: 'MainFont',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: _noteService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _noteService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context)
                          .pushNamed(createOrUpdateNoteRoute, arguments: note);
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }

              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
