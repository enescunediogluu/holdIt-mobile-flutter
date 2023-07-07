import 'package:flutter/material.dart';
import 'package:holdit/constants/routes.dart';
import 'package:holdit/services/cloud/cloud_todo.dart';
import 'package:holdit/services/cloud/firebase_cloud_storage.dart';
import 'package:holdit/wiews/notes/bottom_nav_bar_colors.dart';
import 'package:holdit/wiews/notes/colors.dart';
import 'package:holdit/wiews/todos/todos_list_view.dart';
import '../../services/auth/auth_service.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  late final FirebaseCloudStorage _todoService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _todoService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noteViewBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'ToDo ',
          style: TextStyle(
              color: Color(0XFF000000),
              fontFamily: 'MainFont',
              fontSize: 35,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateTodoRoute);
              },
              icon: const Icon(
                Icons.add_alert,
                color: Color(0xff606C5D),
                size: 36,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _todoService.allTodos(ownerUserId: userId),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allTodos = snapshot.data as Iterable<CloudTodo>;
                return TodosListView(
                  todos: allTodos,
                  onDeleteTodo: (todo) async {
                    await _todoService.deleteTodo(documentId: todo.documentId);
                  },
                  onTap: (todo) {
                    Navigator.of(context)
                        .pushNamed(createUpdateTodoRoute, arguments: todo);
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
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: navBarBgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: homeBackgroundColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: IconButton(
                    icon: Icon(
                      Icons.home,
                      color: homeIconColor,
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, notesViewRoute, (route) => false);
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
                      borderRadius: BorderRadius.circular(15)),
                  child: IconButton(
                    icon: Image.asset(
                      'lib/images/todo_icon.png',
                      color: todoIconColor,
                    ),
                    onPressed: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, todoListRoute, (route) => false);
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
