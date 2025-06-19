import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as dev;
import 'dart:typed_data';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-1.5-flash';

  /// Generate cold outreach email from PDF document
  static Future<String> generateColdEmail(PlatformFile pdfFile) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }
      dev.log('pdfFile: $pdfFile');
       Uint8List fileBytes = pdfFile.bytes ?? Uint8List(0);
      dev.log('Uint8List: $fileBytes');
      // Validate file
      if (pdfFile.bytes == null) {
        throw Exception('PDF file bytes are null');
      }

      final fileExtension = pdfFile.extension?.toLowerCase();
      if (fileExtension != 'pdf') {
        throw Exception('Only PDF files are supported for AI analysis');
      }

      // Encode PDF to base64
      final base64Pdf = base64Encode(pdfFile.bytes!);

      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey');

      final prompt = '''
Prompt:

I am applying for a job and want you to write a highly persuasive cold email to a recruiter. I’ve uploaded my resume, and the company I’m targeting is [Company Name] — please research what the company does and tailor the email accordingly.

Instructions:

Extract my name, LinkedIn profile, and phone number from the resume and include them in the email.

Highlight my experience, projects, and skills from the resume.

Clearly show how my background would be valuable to [Company Name] based on their current work, mission, or products.

Emphasize that I’m:

hardworking

a great team player

actively seeking new opportunities

Use a friendly, confident, and professional tone.

Include a clear call to action (e.g., open to chat, consider me for roles now or in the future).

Assume the resume is attached to the email.

Format the output like this:

Subject:
Quick hello & interest in opportunities at [Company Name]

Body:
Hi,

[Write the body of the persuasive cold email here...]

Thanks,
[My Name from resume]
[LinkedIn link from resume]
[Phone number from resume]

Please go ahead and analyze the resume now and generate the cold email.


''';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
                {
                  'inline_data': {
                    'mime_type': 'application/pdf',
                    'data': base64Pdf
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('No candidates found in AI response');
        }

        final candidate = data['candidates'][0];
        if (candidate['content'] == null ||
            candidate['content']['parts'] == null ||
            candidate['content']['parts'].isEmpty) {
          throw Exception('Invalid response structure from AI');
        }

        final emailText = candidate['content']['parts'][0]['text'] ?? 'No email generated';
        return emailText.trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to generate cold email: $e');
    }
  }

  /// Generate multiple cold email variations
  static Future<List<String>> generateEmailVariations(PlatformFile pdfFile, int count) async {
    try {
      final List<String> variations = [];
      
      for (int i = 0; i < count; i++) {
        final variation = await generateColdEmail(pdfFile);
        variations.add(variation);
        
        // Add a small delay between requests to avoid rate limiting
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      return variations;
    } catch (e) {
      throw Exception('Failed to generate email variations: $e');
    }
  }

  /// Extract key information from PDF for email personalization
  static Future<Map<String, String>> extractKeyInfo(PlatformFile pdfFile) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }

      // Validate file
      if (pdfFile.bytes == null) {
        throw Exception('PDF file bytes are null');
      }

      final base64Pdf = base64Encode(pdfFile.bytes!);
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey');

      final prompt = '''
Please analyze this PDF document and extract key information that would be useful for personalizing a cold outreach email.

Extract the following information in JSON format:
{
  "company_name": "Company or organization name",
  "contact_person": "Key contact person or decision maker",
  "industry": "Industry or business sector",
  "pain_points": "Main challenges or pain points mentioned",
  "opportunities": "Potential opportunities or needs",
  "recent_news": "Recent developments or news mentioned",
  "company_size": "Company size or scale if mentioned",
  "location": "Geographic location if mentioned"
}

Only include information that is explicitly mentioned in the document. If information is not available, use "Not specified".
''';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
                {
                  'inline_data': {
                    'mime_type': 'application/pdf',
                    'data': base64Pdf
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 512,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if candidates exist and are not empty
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('No candidates found in AI response');
        }
        
        final candidate = data['candidates'][0];
        
        // Check if candidate has the required structure
        if (candidate['content'] == null ||
            candidate['content']['parts'] == null ||
            candidate['content']['parts'].isEmpty) {
          throw Exception('Invalid response structure from AI');
        }
        
        final responseText = candidate['content']['parts'][0]['text'] ?? '{}';
        
        // Try to parse JSON response
        try {
          final Map<String, dynamic> jsonData = jsonDecode(responseText);
          return Map<String, String>.from(jsonData);
        } catch (e) {
          // If JSON parsing fails, return default map with "Not specified" values
          return {
            'company_name': 'Not specified',
            'contact_person': 'Not specified',
            'industry': 'Not specified',
            'pain_points': 'Not specified',
            'opportunities': 'Not specified',
            'recent_news': 'Not specified',
            'company_size': 'Not specified',
            'location': 'Not specified',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to extract key information: $e');
    }
  }
} 