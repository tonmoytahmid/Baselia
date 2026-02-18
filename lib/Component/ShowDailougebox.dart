import 'package:flutter/material.dart';

Future<void> showCustomDialog(BuildContext context, void Function()? onPressed) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('You want to shear this post to your profile ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('YES'),
          ),
        ],
      );
    },
  );
}
