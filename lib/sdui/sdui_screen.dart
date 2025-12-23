import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sdui_parser.dart';

class SDUIScreen extends StatefulWidget {
  final String screenId;

  const SDUIScreen({Key? key, required this.screenId}) : super(key: key);

  @override
  _SDUIScreenState createState() => _SDUIScreenState();
}

class _SDUIScreenState extends State<SDUIScreen> {
  Future<Map<String, dynamic>>? _screenFuture;

  @override
  void initState() {
    super.initState();
    _screenFuture = _fetchScreen();
  }

  Future<Map<String, dynamic>> _fetchScreen() async {
    // TODO: Replace with actual backend URL
    final response = await http.get(Uri.parse('http://localhost:8080/api/screen/${widget.screenId}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _screenFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!['title'] ?? 'ColdMail');
            }
            return Text('Loading...');
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _screenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SDUIParser.parse(snapshot.data!['body']);
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
