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

enum NewsVerdict {
  fake,      // High confidence fake news
  real,      // High confidence real news
  uncertain, // Low confidence or mixed signals
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

  /// Get the verdict classification based on confidence and isFake flag
  /// 
  /// Logic:
  /// - confidence < 0.50: UNCERTAIN (not enough evidence either way)
  /// - confidence >= 0.50 && isFake == true: FAKE (likely fake news)
  /// - confidence >= 0.50 && isFake == false: REAL (appears legitimate)
  NewsVerdict get verdict {
    if (confidence < 0.50) {
      return NewsVerdict.uncertain;
    }
    return isFake ? NewsVerdict.fake : NewsVerdict.real;
  }

  /// Get a human-readable verdict label
  String get verdictLabel {
    switch (verdict) {
      case NewsVerdict.fake:
        return 'Likely Fake News';
      case NewsVerdict.real:
        return 'Appears Legitimate';
      case NewsVerdict.uncertain:
        return 'Uncertain';
    }
  }

  /// Get a detailed verdict description
  String get verdictDescription {
    switch (verdict) {
      case NewsVerdict.fake:
        return 'This article shows strong indicators of misinformation';
      case NewsVerdict.real:
        return 'This article appears to follow journalistic standards';
      case NewsVerdict.uncertain:
        return 'This article appears to follow journalistic standards with proper sourcing. However, always cross-reference important information with multiple trusted sources.';
    }
  }

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
