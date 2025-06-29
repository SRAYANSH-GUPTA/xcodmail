import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class EmailTemplate {
  final String id;
  final String companyName;
  final String position;
  final String emailContent;
  final String templateType;
  final DateTime createdAt;

  EmailTemplate({
    required this.id,
    required this.companyName,
    required this.position,
    required this.emailContent,
    required this.templateType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'position': position,
      'emailContent': emailContent,
      'templateType': templateType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      id: json['id'],
      companyName: json['companyName'],
      position: json['position'],
      emailContent: json['emailContent'],
      templateType: json['templateType'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TemplateService {
  static const String _templatesKey = 'email_templates';

  /// Save email template to local storage
  static Future<void> saveTemplate(EmailTemplate template) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList(_templatesKey) ?? [];
      
      // Add new template
      templatesJson.add(jsonEncode(template.toJson()));
      
      // Keep only the last 50 templates to prevent storage overflow
      if (templatesJson.length > 50) {
        templatesJson.removeRange(0, templatesJson.length - 50);
      }
      
      await prefs.setStringList(_templatesKey, templatesJson);
      dev.log('Template saved successfully: ${template.id}');
    } catch (e) {
      dev.log('Error saving template: $e');
      throw Exception('Failed to save template: $e');
    }
  }

  /// Get all saved templates
  static Future<List<EmailTemplate>> getTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList(_templatesKey) ?? [];
      
      final templates = <EmailTemplate>[];
      for (final templateJson in templatesJson) {
        try {
          final templateData = jsonDecode(templateJson);
          templates.add(EmailTemplate.fromJson(templateData));
        } catch (e) {
          dev.log('Error parsing template: $e');
          // Skip invalid templates
        }
      }
      
      // Sort by creation date (newest first)
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return templates;
    } catch (e) {
      dev.log('Error getting templates: $e');
      throw Exception('Failed to get templates: $e');
    }
  }

  /// Delete a specific template
  static Future<void> deleteTemplate(String templateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList(_templatesKey) ?? [];
      
      final updatedTemplates = <String>[];
      for (final templateJson in templatesJson) {
        try {
          final templateData = jsonDecode(templateJson);
          if (templateData['id'] != templateId) {
            updatedTemplates.add(templateJson);
          }
        } catch (e) {
          dev.log('Error parsing template during deletion: $e');
          // Keep invalid templates to avoid data loss
          updatedTemplates.add(templateJson);
        }
      }
      
      await prefs.setStringList(_templatesKey, updatedTemplates);
      dev.log('Template deleted successfully: $templateId');
    } catch (e) {
      dev.log('Error deleting template: $e');
      throw Exception('Failed to delete template: $e');
    }
  }

  /// Clear all templates
  static Future<void> clearAllTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_templatesKey);
      dev.log('All templates cleared successfully');
    } catch (e) {
      dev.log('Error clearing templates: $e');
      throw Exception('Failed to clear templates: $e');
    }
  }

  /// Get templates by type
  static Future<List<EmailTemplate>> getTemplatesByType(String templateType) async {
    final allTemplates = await getTemplates();
    return allTemplates.where((template) => template.templateType == templateType).toList();
  }

  /// Generate unique template ID
  static String generateTemplateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 