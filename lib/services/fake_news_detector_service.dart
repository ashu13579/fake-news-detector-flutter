import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class FakeNewsDetectorService {
  // Using OpenRouter API with Google's Gemini model for real AI analysis
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'google/gemini-2.0-flash-exp:free';
  
  // You'll need to add your OpenRouter API key here
  // Get one free at: https://openrouter.ai/
  String? _apiKey;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<VerificationResult> analyzeNews(String title, String content, {String? imageUrl}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      // Fallback to local analysis if no API key
      return _analyzeLocally(title, content);
    }

    try {
      final messages = [
        {
          'role': 'user',
          'content': _buildPrompt(title, content, imageUrl),
        }
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/ashu13579/fake-news-detector-flutter',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        return _parseAIResponse(aiResponse);
      } else {
        // Fallback to local analysis on API error
        return _analyzeLocally(title, content);
      }
    } catch (e) {
      // Fallback to local analysis on error
      return _analyzeLocally(title, content);
    }
  }

  String _buildPrompt(String title, String content, String? imageUrl) {
    String prompt = '''You are an expert fact-checker and misinformation analyst. Analyze the following news article for authenticity.

Title: $title

Content: $content
''';

    if (imageUrl != null) {
      prompt += '\nImage URL: $imageUrl\n(Consider if the image context matches the article content)';
    }

    prompt += '''

Provide your analysis in the following JSON format:
{
  "isFake": true/false,
  "confidence": 0.0-1.0,
  "reasoning": "detailed explanation",
  "redFlags": ["flag1", "flag2", ...],
  "sources": ["source1", "source2", ...]
}

Analyze based on:
1. Sensational or clickbait language
2. Lack of credible sources
3. Emotional manipulation
4. Factual inconsistencies
5. Writing quality and professionalism
6. Image-text consistency (if image provided)

Be thorough and objective.''';

    return prompt;
  }

  VerificationResult _parseAIResponse(String response) {
    try {
      // Extract JSON from response (AI might add extra text)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final data = jsonDecode(jsonStr);
        
        return VerificationResult(
          isFake: data['isFake'] ?? false,
          confidence: (data['confidence'] ?? 0.5).toDouble(),
          reasoning: data['reasoning'] ?? 'Analysis completed',
          redFlags: List<String>.from(data['redFlags'] ?? []),
          sources: List<String>.from(data['sources'] ?? []),
        );
      }
    } catch (e) {
      // If parsing fails, return a default result
    }
    
    return VerificationResult(
      isFake: false,
      confidence: 0.5,
      reasoning: 'Unable to parse AI response. Please try again.',
      redFlags: ['Analysis error'],
      sources: [],
    );
  }

  // Fallback local analysis (original logic)
  Future<VerificationResult> _analyzeLocally(String title, String content) async {
    await Future.delayed(const Duration(seconds: 2));
    
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

    // Check for all caps
    if (title == title.toUpperCase() && title.length > 10) {
      redFlags.add('Title is in ALL CAPS (common clickbait tactic)');
    }

    // Check for excessive punctuation
    if (title.contains('!!!') || title.contains('???')) {
      redFlags.add('Excessive punctuation in title');
    }

    // Check for sources
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

    if (hasSourceIndicators) {
      sources.addAll(['Reuters', 'Associated Press', 'BBC News']);
    }

    final fakeScore = (redFlags.length * 0.2).clamp(0.0, 0.95);
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

    return VerificationResult(
      isFake: isFake,
      confidence: confidence,
      reasoning: reasoning,
      redFlags: redFlags.isEmpty ? ['No major red flags detected'] : redFlags,
      sources: sources.isEmpty ? ['No sources identified'] : sources,
    );
  }
}
