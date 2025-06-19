import '../entities/generated_email.dart';
import '../entities/resume.dart';
import '../repositories/gemini_repository.dart';

class GenerateEmailUseCase {
  final GeminiRepository repository;

  GenerateEmailUseCase(this.repository);

  Future<GeneratedEmail> execute({
    required Resume resume,
    required String companyName,
  }) async {
    return await repository.generateColdEmail(
      resume: resume,
      companyName: companyName,
    );
  }
} 