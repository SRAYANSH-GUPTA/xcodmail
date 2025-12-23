import 'package:flutter/material.dart';

class SDUIRow extends StatelessWidget {
  final List<Widget> children;
  final Map<String, dynamic> properties;

  const SDUIRow({Key? key, required this.children, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}
