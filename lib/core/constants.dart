class AppConstants {
  static const String appName = 'ColdMail';
  static const String appVersion = '1.0.0';
  
  // Gemini API
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Gmail
  static const String gmailScheme = 'mailto';
  
  // UI Constants
  static const double cardRadius = 16.0;
  static const double cardElevation = 8.0;
  static const double cardOpacity = 0.9;
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // File Types
  static const List<String> supportedFileTypes = ['pdf'];
} 