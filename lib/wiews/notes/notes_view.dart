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
import 'package:holdit/wiews/notes/bottom_nav_bar_colors.dart';
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
      backgroundColor: const Color(0xffFDF4F5),
      appBar: AppBar(
        title: const Text(
          'Your Notes',
          style: TextStyle(
              color: Color(0XFF000000),
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
            color: const Color(0xffFDF4F5),
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Log out',
                        style: TextStyle(
                            fontFamily: 'MainFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      ),
                    ],
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
                    await _noteService.deleteNote(documentId: note.documentId);
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
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: navBarBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: homeBackgroundColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                    icon: Icon(
                      Icons.home,
                      color: homeIconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        todoIconColor = navBarTabActiveColor;
                        todoBackgroundColor = navBarBgColor;
                        homeBackgroundColor = navBarTabActiveColor;
                        homeIconColor = navBarBgColor;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: todoBackgroundColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                    icon: Image.asset(
                      'lib/images/todo_icon.png',
                      color: todoIconColor,
                    ),
                    onPressed: () async {
                      Navigator.pushNamed(context, todoListRoute);
                      setState(() {
                        homeIconColor = navBarTabActiveColor;
                        homeBackgroundColor = navBarBgColor;
                        todoIconColor = navBarBgColor;
                        todoBackgroundColor = navBarTabActiveColor;
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
