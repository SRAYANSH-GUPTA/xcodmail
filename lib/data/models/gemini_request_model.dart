class GeminiRequestModel {
  final List<Content> contents;

  GeminiRequestModel({required this.contents});

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map((content) => content.toJson()).toList(),
    };
  }
}

class Content {
  final List<Part> parts;

  Content({required this.parts});

  Map<String, dynamic> toJson() {
    return {
      'parts': parts.map((part) => part.toJson()).toList(),
    };
  }
}

class Part {
  final String text;

  Part({required this.text});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
} 