import '../entities/generated_email.dart';
import '../entities/resume.dart';

abstract class GeminiRepository {
  Future<GeneratedEmail> generateColdEmail({
    required Resume resume,
    required String companyName,
  });
} 