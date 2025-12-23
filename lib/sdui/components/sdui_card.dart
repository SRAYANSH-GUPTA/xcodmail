import 'package:flutter/material.dart';

class SDUICard extends StatelessWidget {
  final List<Widget> children;
  final Map<String, dynamic> properties;

  const SDUICard({Key? key, required this.children, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
