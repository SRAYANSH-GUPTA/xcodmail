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
Please analyze this PDF document and generate a personalized cold outreach email. 

The PDF contains information about a potential client, company, or business opportunity. Based on the content, create a compelling cold email that:

1. **Personalization**: References specific details from the PDF to show you've done your research
2. **Value Proposition**: Clearly articulates what value you can provide
3. **Call to Action**: Includes a specific, actionable next step
4. **Professional Tone**: Maintains a professional yet approachable tone
5. **Concise**: Keeps the email under 150 words for better engagement

Please structure the email with:
- A compelling subject line
- Personalized opening that references the PDF content
- Clear value proposition
- Specific call to action
- Professional closing

Format the response as a complete email ready to send, including the subject line.

Focus on creating genuine value and building a relationship rather than just selling.
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