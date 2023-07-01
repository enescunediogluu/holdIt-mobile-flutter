import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:holdit/services/cloud/cloud_note.dart';
import 'package:holdit/utilities/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                icon: Icons.delete,
                backgroundColor: Colors.deepPurple,
                onPressed: (context) async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
              )
            ],
          ),
          child: ListTile(
            onTap: () {
              onTap(note);
            },
            title: Container(
              height: 100,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 214, 165, 227),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                'lib/images/note_icon.png',
                                color: const Color(0xff4E3636),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(note.text,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400, fontSize: 18),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
