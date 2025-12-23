import 'package:flutter/material.dart';
import '../sdui_screen.dart';

class SDUIButton extends StatelessWidget {
  final Map<String, dynamic> properties;
  final Map<String, dynamic>? action;

  const SDUIButton({Key? key, required this.properties, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String label = properties['label'] ?? 'Button';

    return ElevatedButton(
      onPressed: () {
        if (action != null) {
          _handleAction(context, action!);
        }
      },
      child: Text(label),
    );
  }

  void _handleAction(BuildContext context, Map<String, dynamic> action) {
    String type = action['type'];
    String? data = action['data'];

    if (type == 'navigate' && data != null) {
      // For now, we assume data is the screen ID, e.g., "/email_send" -> "email_send"
      String screenId = data.replaceAll('/', '');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SDUIScreen(screenId: screenId)),
      );
    } else if (type == 'api_call') {
      // TODO: Implement API call logic
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API Call: $data')));
    } else if (type == 'pick_file') {
      // TODO: Implement file picker
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick File')));
    }
  }
}
