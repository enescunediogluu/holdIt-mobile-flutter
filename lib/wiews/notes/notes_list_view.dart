import 'package:flutter/material.dart';
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
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Container(
            height: 100,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(note.text,
                        style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'MainFont',
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        onDeleteNote(note);
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.deepPurple,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
