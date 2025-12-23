import 'package:flutter/material.dart';

class SDUIColumn extends StatelessWidget {
  final List<Widget> children;
  final Map<String, dynamic> properties;

  const SDUIColumn({Key? key, required this.children, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
