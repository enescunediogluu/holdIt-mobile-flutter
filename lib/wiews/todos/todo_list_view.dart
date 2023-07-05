import 'package:flutter/material.dart';
import 'package:holdit/constants/routes.dart';
import 'package:holdit/wiews/notes/bottom_nav_bar_colors.dart';
import 'package:holdit/wiews/notes/colors.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
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
              onPressed: () {},
              icon: const Icon(
                Icons.add_alert,
                color: Colors.deepPurple,
                size: 36,
              ),
            ),
          )
        ],
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
