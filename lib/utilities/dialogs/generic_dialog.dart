import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffFDF4F5),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          contentTextStyle: const TextStyle(
            fontFamily: 'MainFont',
            color: Colors.black,
            fontSize: 20,
          ),
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 25,
                fontFamily: 'MainFont',
                fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: options.keys.map((optionTitle) {
            final T value = options[optionTitle];
            return TextButton(
                onPressed: () {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurple,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      optionTitle,
                      style: const TextStyle(
                        fontFamily: 'MainFont',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ));
          }).toList(),
        );
      });
}
