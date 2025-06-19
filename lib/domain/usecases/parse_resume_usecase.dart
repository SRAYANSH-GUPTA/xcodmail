import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class ParseResumeUseCase {
  final ResumeRepository repository;

  ParseResumeUseCase(this.repository);

  Future<Resume> execute(String filePath) async {
    return await repository.parsePdfResume(filePath);
  }
} 