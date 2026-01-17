import 'dart:math';
import '../models/news_article.dart';

class FakeNewsDetectorService {
  // Simulated AI-powered fake news detection
  // In production, this would call a real ML API
  Future<VerificationResult> analyzeNews(String title, String content) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Analyze content for fake news indicators
    final analysis = _analyzeContent(title, content);
    
    return VerificationResult(
      isFake: analysis['isFake'],
      confidence: analysis['confidence'],
      reasoning: analysis['reasoning'],
      redFlags: analysis['redFlags'],
      sources: analysis['sources'],
    );
  }

  Map<String, dynamic> _analyzeContent(String title, String content) {
    final combinedText = '$title $content'.toLowerCase();
    final redFlags = <String>[];
    final sources = <String>[];
    
    // Check for sensational language
    final sensationalWords = [
      'shocking', 'unbelievable', 'miracle', 'secret', 'they don\'t want you to know',
      'breaking', 'urgent', 'must see', 'you won\'t believe', 'doctors hate'
    ];
    
    for (var word in sensationalWords) {
      if (combinedText.contains(word)) {
        redFlags.add('Contains sensational language: "$word"');
      }
    }

    // Check for all caps (common in fake news)
    if (title == title.toUpperCase() && title.length > 10) {
      redFlags.add('Title is in ALL CAPS (common clickbait tactic)');
    }

    // Check for excessive punctuation
    if (title.contains('!!!') || title.contains('???')) {
      redFlags.add('Excessive punctuation in title');
    }

    // Check for lack of sources
    final hasSourceIndicators = combinedText.contains('according to') ||
        combinedText.contains('study shows') ||
        combinedText.contains('research') ||
        combinedText.contains('expert');
    
    if (!hasSourceIndicators && content.length > 100) {
      redFlags.add('No clear sources or citations mentioned');
    }

    // Check for emotional manipulation
    final emotionalWords = ['outrage', 'scandal', 'conspiracy', 'cover-up', 'exposed'];
    for (var word in emotionalWords) {
      if (combinedText.contains(word)) {
        redFlags.add('Uses emotional manipulation: "$word"');
      }
    }

    // Generate credible sources (simulated)
    if (hasSourceIndicators) {
      sources.addAll([
        'Reuters',
        'Associated Press',
        'BBC News',
      ]);
    }

    // Calculate fake probability based on red flags
    final fakeScore = min(redFlags.length * 0.2, 0.95);
    final isFake = fakeScore > 0.5;
    final confidence = isFake ? fakeScore : (1 - fakeScore);

    String reasoning;
    if (isFake) {
      reasoning = 'This article shows ${redFlags.length} indicators commonly associated with fake news. '
          'It uses sensational language, lacks credible sources, and may be designed to manipulate emotions. '
          'Please verify this information with trusted news sources before sharing.';
    } else {
      reasoning = 'This article appears to be legitimate based on our analysis. '
          'It uses measured language, cites sources, and follows journalistic standards. '
          'However, always cross-reference important information with multiple trusted sources.';
    }

    return {
      'isFake': isFake,
      'confidence': confidence,
      'reasoning': reasoning,
      'redFlags': redFlags.isEmpty ? ['No major red flags detected'] : redFlags,
      'sources': sources.isEmpty ? ['No sources identified'] : sources,
    };
  }
}
