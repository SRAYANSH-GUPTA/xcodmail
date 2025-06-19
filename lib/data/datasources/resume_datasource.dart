import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../domain/entities/resume.dart';

class ResumeDataSource {
  Future<Resume> parsePdfResume(String filePath) async {
    try {
      final file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages
      String content = '';
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        content += extractor.extractText(startPageIndex: i);
        if (i < document.pages.count - 1) {
          content += '\n';
        }
      }
      
      // Dispose the document
      document.dispose();
      
      return Resume(
        content: content.trim(),
        fileName: file.path.split('/').last,
        uploadDate: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to parse PDF: $e');
    }
  }
} 