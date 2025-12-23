import 'package:flutter/material.dart';

class SDUIList extends StatelessWidget {
  final List<Widget> children;
  final Map<String, dynamic> properties;

  const SDUIList({Key? key, required this.children, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: children,
    );
  }
}
