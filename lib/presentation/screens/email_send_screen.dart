import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

class EmailSendScreen extends StatefulWidget {
  const EmailSendScreen({super.key});

  @override
  State<EmailSendScreen> createState() => _EmailSendScreenState();
}

class _EmailSendScreenState extends State<EmailSendScreen> {
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recipientsController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  PlatformFile? _htmlFile;
  List<PlatformFile> _attachments = [];
  String _log = '';
  bool _isSending = false;

  @override
  void dispose() {
    _senderController.dispose();
    _passwordController.dispose();
    _recipientsController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickHtmlFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['html', 'htm']);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _htmlFile = result.files.first;
        _bodyController.text = String.fromCharCodes(_htmlFile!.bytes ?? []);
      });
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  void _appendLog(String message) {
    setState(() {
      _log += message + '\n';
    });
  }

  void _sendEmails() async {
    final sender = _senderController.text.trim();
    final password = _passwordController.text.trim();
    final recipients = _recipientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final subject = _subjectController.text.trim();
    String body = _bodyController.text;
    final attachments = _attachments;

    // If HTML file is uploaded, use its content as body
    if (_htmlFile != null && _htmlFile!.bytes != null) {
      body = String.fromCharCodes(_htmlFile!.bytes!);
    }

    if (sender.isEmpty || password.isEmpty || recipients.isEmpty || subject.isEmpty || (body.isEmpty)) {
      _appendLog('Please fill all required fields. (Email body is required unless an HTML file is uploaded)');
      return;
    }

    setState(() { _isSending = true; });
    int successCount = 0;
    for (final recipient in recipients) {
      try {
        final message = Message()
          ..from = Address(sender)
          ..recipients.add(recipient)
          ..subject = subject
          ..html = body;

        for (final file in attachments) {
          if (file.path != null) {
            message.attachments.add(FileAttachment(File(file.path!)));
          } else if (file.bytes != null) {
            _appendLog('Attachment from memory not supported: ${file.name}');
          }
        }

        final smtpServer = gmail(sender, password);
        final sendReport = await send(message, smtpServer);
        successCount++;
        _appendLog('Email sent to: $recipient\n$sendReport');
      } catch (e) {
        _appendLog('Failed to send to $recipient: $e');
      }
    }
    _appendLog('Summary: $successCount/${recipients.length} emails sent successfully.');
    setState(() { _isSending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Sender Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recipientsController,
              decoration: const InputDecoration(
                labelText: 'Recipients (comma separated)',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickHtmlFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload HTML'),
                ),
                const SizedBox(width: 12),
                if (_htmlFile != null) Text(_htmlFile!.name),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Email Body (HTML)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: 15,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAttachments,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Attachments'),
                ),
                const SizedBox(width: 12),
                if (_attachments.isNotEmpty)
                  Text('${_attachments.length} file(s) selected'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendEmails,
                icon: const Icon(Icons.send),
                label: _isSending ? const Text('Sending...') : const Text('Send Emails'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                child: Text(_log, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 