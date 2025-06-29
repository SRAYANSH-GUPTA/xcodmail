class AppConstants {
  static const String appName = 'ColdMail';
  static const String appVersion = '1.0.0';
  
  // Gemini API
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
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

  // Technical Positions and Job Titles
  static const List<String> technicalPositions = [
    'Software Engineer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Mobile App Developer',
    'iOS Developer',
    'Android Developer',
    'Flutter Developer',
    'React Native Developer',
    'DevOps Engineer',
    'Site Reliability Engineer (SRE)',
    'Data Engineer',
    'Data Scientist',
    'Machine Learning Engineer',
    'AI Engineer',
    'Cloud Engineer',
    'AWS Solutions Architect',
    'Azure Developer',
    'Google Cloud Engineer',
    'System Administrator',
    'Network Engineer',
    'Security Engineer',
    'Cybersecurity Analyst',
    'QA Engineer',
    'Test Automation Engineer',
    'Product Manager',
    'Technical Product Manager',
    'Engineering Manager',
    'Tech Lead',
    'Software Architect',
    'UI/UX Designer',
    'UX Researcher',
    'Technical Writer',
    'Solutions Architect',
    'Database Administrator',
    'Blockchain Developer',
    'Game Developer',
    'Embedded Systems Engineer',
    'Robotics Engineer',
    'Computer Vision Engineer',
    'NLP Engineer',
    'Research Scientist',
    'Technical Consultant',
    'Software Consultant',
    'Freelance Developer',
    'Other (Custom)',
  ];

  // Email Template Types
  static const String generalTemplate = 'General';
  static const String curatedTemplate = 'Curated';
} 