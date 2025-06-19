import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants.dart';
import '../models/gemini_request_model.dart' as request;
import '../models/gemini_response_model.dart' as response;
import '../../domain/entities/generated_email.dart';
import '../../domain/entities/resume.dart';

class GeminiDataSource {
  Future<GeneratedEmail> generateColdEmail({
    required Resume resume,
    required String companyName,
  }) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }

      final prompt = _buildPrompt(resume, companyName);
      
      final requestModel = request.GeminiRequestModel(
        contents: [
          request.Content(
            parts: [
              request.Part(text: prompt),
            ],
          ),
        ],
      );

      final httpResponse = await http.post(
        Uri.parse('${AppConstants.geminiApiUrl}?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      if (httpResponse.statusCode == 200) {
        final responseData = jsonDecode(httpResponse.body);
        final geminiResponse = response.GeminiResponseModel.fromJson(responseData);
        
        if (geminiResponse.candidates.isNotEmpty) {
          final generatedText = geminiResponse.candidates.first.content.parts.first.text;
          final emailParts = _parseGeneratedEmail(generatedText);
          
          return GeneratedEmail(
            subject: emailParts['subject'] ?? 'Job Opportunity / Collaboration',
            body: emailParts['body'] ?? generatedText,
            companyName: companyName,
            generatedAt: DateTime.now(),
          );
        } else {
          throw Exception('No response generated from Gemini API');
        }
      } else {
        throw Exception('Failed to generate email: ${httpResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating email: $e');
    }
  }

  String _buildPrompt(Resume resume, String companyName) {
    return '''
Using this resume:
${resume.content}

Generate a concise, professional cold outreach email for the company: $companyName

Please format the response as:
Subject: [Email Subject]
Body: [Email Body]

The email should be:
- Professional and concise
- Highlight relevant skills from the resume
- Show genuine interest in the company
- Include a clear call to action
- Be under 200 words
''';
  }

  Map<String, String> _parseGeneratedEmail(String generatedText) {
    final lines = generatedText.split('\n');
    String subject = 'Job Opportunity / Collaboration';
    String body = generatedText;

    for (final line in lines) {
      if (line.toLowerCase().startsWith('subject:')) {
        subject = line.substring(8).trim();
      } else if (line.toLowerCase().startsWith('body:')) {
        body = line.substring(5).trim();
        break;
      }
    }

    return {
      'subject': subject,
      'body': body,
    };
  }
} 