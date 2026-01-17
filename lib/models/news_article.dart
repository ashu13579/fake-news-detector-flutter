class NewsArticle {
  final String title;
  final String content;
  final String? url;
  final String? imageUrl;
  final DateTime timestamp;
  final VerificationResult? verificationResult;

  NewsArticle({
    required this.title,
    required this.content,
    this.url,
    this.imageUrl,
    required this.timestamp,
    this.verificationResult,
  });

  NewsArticle copyWith({
    String? title,
    String? content,
    String? url,
    String? imageUrl,
    DateTime? timestamp,
    VerificationResult? verificationResult,
  }) {
    return NewsArticle(
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      verificationResult: verificationResult ?? this.verificationResult,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'verificationResult': verificationResult?.toJson(),
    };
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      content: json['content'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      verificationResult: json['verificationResult'] != null
          ? VerificationResult.fromJson(json['verificationResult'])
          : null,
    );
  }
}

class VerificationResult {
  final bool isFake;
  final double confidence;
  final String reasoning;
  final List<String> redFlags;
  final List<String> sources;

  VerificationResult({
    required this.isFake,
    required this.confidence,
    required this.reasoning,
    required this.redFlags,
    required this.sources,
  });

  Map<String, dynamic> toJson() {
    return {
      'isFake': isFake,
      'confidence': confidence,
      'reasoning': reasoning,
      'redFlags': redFlags,
      'sources': sources,
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isFake: json['isFake'],
      confidence: json['confidence'].toDouble(),
      reasoning: json['reasoning'],
      redFlags: List<String>.from(json['redFlags']),
      sources: List<String>.from(json['sources']),
    );
  }
}
