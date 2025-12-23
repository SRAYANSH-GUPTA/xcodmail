import 'package:flutter/material.dart';

class SDUIText extends StatelessWidget {
  final Map<String, dynamic> properties;

  const SDUIText({Key? key, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = properties['text'] ?? '';
    String style = properties['style'] ?? 'body';

    TextStyle textStyle;
    switch (style) {
      case 'headline':
        textStyle = Theme.of(context).textTheme.headlineLarge!;
        break;
      case 'subtitle':
        textStyle = Theme.of(context).textTheme.titleMedium!;
        break;
      default:
        textStyle = Theme.of(context).textTheme.bodyMedium!;
    }

    return Text(text, style: textStyle);
  }
}
