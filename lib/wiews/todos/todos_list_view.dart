import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:holdit/services/cloud/cloud_todo.dart';
import 'package:holdit/utilities/dialogs/delete_todo_dialog.dart';

typedef TodoCallBack = void Function(CloudTodo todo);

class TodosListView extends StatefulWidget {
  final Iterable<CloudTodo> todos;
  final TodoCallBack onDeleteTodo;
  final TodoCallBack onTap;

  const TodosListView({
    super.key,
    required this.todos,
    required this.onDeleteTodo,
    required this.onTap,
  });

  @override
  State<TodosListView> createState() => _TodosListViewState();
}

class _TodosListViewState extends State<TodosListView> {
  bool checkBoxIcon = false;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.todos.length,
      itemBuilder: (context, index) {
        final todo = widget.todos.elementAt(index);
        return Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                icon: Icons.delete,
                backgroundColor: const Color(0xff606C5D),
                onPressed: (context) async {
                  final shouldDelete = await showDeleteTodoDialog(context);
                  if (shouldDelete) {
                    widget.onDeleteTodo(todo);
                  }
                },
              )
            ],
          ),
          child: ListTile(
            onTap: () {
              widget.onTap(todo);
            },
            title: Container(
              height: 80,
              decoration: BoxDecoration(
                  color: const Color(0xff22A699).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                checkBoxIcon = !checkBoxIcon;
                              });
                            },
                            child: IconButton(
                                icon: Icon(checkBoxIcon
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank),
                                onPressed: null),
                          ),
                          Expanded(
                            child: Text(todo.text,
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
