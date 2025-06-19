import '../entities/resume.dart';

abstract class ResumeRepository {
  Future<Resume> parsePdfResume(String filePath);
} 