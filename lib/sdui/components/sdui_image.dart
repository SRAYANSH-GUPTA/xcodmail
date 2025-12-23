import 'package:flutter/material.dart';

class SDUIImage extends StatelessWidget {
  final Map<String, dynamic> properties;

  const SDUIImage({Key? key, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = properties['url'] ?? '';
    double? width = properties['width']?.toDouble();
    double? height = properties['height']?.toDouble();

    if (url.isEmpty) {
      return SizedBox(width: width, height: height, child: Icon(Icons.image_not_supported));
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
    );
  }
}
