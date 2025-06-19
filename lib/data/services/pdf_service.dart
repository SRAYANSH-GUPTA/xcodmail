import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class PdfService {
  /// Extracts text content from a PDF file
  static Future<String> extractTextFromPdf(PlatformFile file) async {
    try {
      // Load the PDF document from bytes
      final PdfDocument document = PdfDocument(inputBytes: file.bytes);
      
      // Extract text from all pages
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String extractedText = '';
      
      // Extract text from each page
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i);
        extractedText += pageText;
        
        // Add a page separator if not the last page
        if (i < document.pages.count - 1) {
          extractedText += '\n\n--- Page ${i + 2} ---\n\n';
        }
      }
      
      // Dispose the document
      document.dispose();
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extracts text content from a PDF file path
  static Future<String> extractTextFromPdfPath(String filePath) async {
    try {
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      // Load the PDF document from bytes
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String extractedText = '';
      
      // Extract text from each page
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i);
        extractedText += pageText;
        
        // Add a page separator if not the last page
        if (i < document.pages.count - 1) {
          extractedText += '\n\n--- Page ${i + 2} ---\n\n';
        }
      }
      
      // Dispose the document
      document.dispose();
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Gets basic information about the PDF
  static Future<Map<String, dynamic>> getPdfInfo(PlatformFile file) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: file.bytes);
      
      final Map<String, dynamic> info = {
        'pageCount': document.pages.count,
        'fileSize': file.size,
        'fileName': file.name,
        'fileExtension': file.extension,
      };
      
      // Try to get document properties if available
      try {
        final PdfDocumentInformation documentInfo = document.documentInformation;
        info['title'] = documentInfo.title;
        info['author'] = documentInfo.author;
        info['subject'] = documentInfo.subject;
        info['creator'] = documentInfo.creator;
        info['producer'] = documentInfo.producer;
      } catch (e) {
        // Document information might not be available
        info['title'] = null;
        info['author'] = null;
        info['subject'] = null;
        info['creator'] = null;
        info['producer'] = null;
      }
      
      document.dispose();
      return info;
    } catch (e) {
      throw Exception('Failed to get PDF info: $e');
    }
  }
} 