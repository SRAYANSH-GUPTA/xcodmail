import 'package:flutter/material.dart';

class SDUIInput extends StatelessWidget {
  final Map<String, dynamic> properties;

  const SDUIInput({Key? key, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String hint = properties['hint'] ?? '';
    int lines = properties['lines'] ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
