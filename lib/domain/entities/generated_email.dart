class GeneratedEmail {
  final String subject;
  final String body;
  final String companyName;
  final DateTime generatedAt;

  const GeneratedEmail({
    required this.subject,
    required this.body,
    required this.companyName,
    required this.generatedAt,
  });

  GeneratedEmail copyWith({
    String? subject,
    String? body,
    String? companyName,
    DateTime? generatedAt,
  }) {
    return GeneratedEmail(
      subject: subject ?? this.subject,
      body: body ?? this.body,
      companyName: companyName ?? this.companyName,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
} 