class Resume {
  final String content;
  final String fileName;
  final DateTime uploadDate;

  const Resume({
    required this.content,
    required this.fileName,
    required this.uploadDate,
  });

  Resume copyWith({
    String? content,
    String? fileName,
    DateTime? uploadDate,
  }) {
    return Resume(
      content: content ?? this.content,
      fileName: fileName ?? this.fileName,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
} 