import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:coldmail/core/env.dart';   

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-1.5-flash';

  /// Generate cold outreach email from PDF document with company and position details
  static Future<String> generateColdEmail(
    PlatformFile pdfFile, {
    required String companyName,
    required String position,
    required String templateType,
  }) async {
    try {
      final apiKey = Env.geminiApiKey;
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

      String prompt;
      if (templateType == 'General') {
    prompt = '''
Prompt:

I am applying for a $position position at $companyName and want you to write a highly persuasive cold email to a recruiter. I've uploaded my resume—use it to craft a tailored message.

Instructions:

1. Research $companyName to understand:
   - What the company does, its products/services, and mission
   - Recent news, milestones, or challenges
   - Company culture and values
   - Technology stack or industry focus

2. Extract my name, LinkedIn profile, and phone number from the resume and include them.

3. Highlight the most relevant skills, experiences, or projects from my resume that align with the $position role.

4. Clearly connect my background with $companyName’s needs, mission, or current initiatives.

5. Use a friendly, confident, and professional tone.

6. Keep the email between 150–200 words.

Output format:

Subject: Inquiry about $position at $companyName

Body:
Hi [Recruiter's Name or Hiring Manager],

[Write the body of the persuasive cold email here…]

Thanks,  
[My Name from resume]

Please analyze my resume and research $companyName to generate this cold email.
''';
} else {
    prompt = '''
Prompt:

Generate a concise, personalized cold email (max 150 words) for a $position role at $companyName. I've uploaded my resume—use it to reference my name, contact info, skills, experience, and key projects.

Instructions:

1. Research $companyName to understand:
   - Their business model, products/services, and tech stack
   - Recent news, projects, or hiring trends
   - Their values, culture, and key challenges

2. Match my resume with $companyName’s needs:
   - Highlight specific skills or experiences relevant to their current goals or challenges
   - Show how I can add value quickly

3. Write in bullet points for clarity and impact.

4. Use a confident, enthusiastic, and professional tone.

5. Keep it under 150 words.

Output format:

Subject: $position at $companyName – [1-line value proposition]

Body:
Hi [Recruiter's Name or Hiring Manager],

• [Bullet point 1: tailored value or skill]  
• [Bullet point 2: relevant project or experience]  
• [Bullet point 3: company-specific insight or alignment]

Thanks,  
[My Name from resume]

Please analyze my resume and research $companyName thoroughly before writing.
''';


      }

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
            'temperature': templateType == 'General' ? 0.1 : 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': templateType == 'General' ? 1024 : 1500,
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
  static Future<List<String>> generateEmailVariations(
    PlatformFile pdfFile, {
    required String companyName,
    required String position,
    required String templateType,
    int count = 3,
  }) async {
    try {
      final List<String> variations = [];
      
      for (int i = 0; i < count; i++) {
        final variation = await generateColdEmail(
          pdfFile,
          companyName: companyName,
          position: position,
          templateType: templateType,
        );
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
  "full_name": "Full name of the person",
  "email": "Email address if available",
  "phone": "Phone number if available",
  "linkedin": "LinkedIn profile URL if available",
  "key_skills": "Most relevant technical skills and technologies",
  "experience_years": "Years of experience",
  "key_projects": "Notable projects or achievements",
  "education": "Educational background",
  "certifications": "Professional certifications if any",
  "languages": "Programming languages known",
  "frameworks": "Frameworks and tools experience",
  "industries": "Industries worked in",
  "achievements": "Key achievements or awards"
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
          // If JSON parsing fails, return default map winitith "Not specified" values
          return {
            'full_name': 'Not specified',
            'email': 'Not specified',
            'phone': 'Not specified',
            'linkedin': 'Not specified',
            'key_skills': 'Not specified',
            'experience_years': 'Not specified',
            'key_projects': 'Not specified',
            'education': 'Not specified',
            'certifications': 'Not specified',
            'languages': 'Not specified',
            'frameworks': 'Not specified',
            'industries': 'Not specified',
            'achievements': 'Not specified',
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