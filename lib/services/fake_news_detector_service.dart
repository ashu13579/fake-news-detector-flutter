import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class FakeNewsDetectorService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'google/gemini-2.0-flash-exp:free';
  
  String? _apiKey;

  void setApiKey(String key) {
    _apiKey = key;
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<VerificationResult> analyzeNews(
    String title,
    String content, {
    String? url,
    String? imageUrl,
  }) async {
    if (!hasApiKey) {
      return _fallbackAnalysis(title, content);
    }

    try {
      final prompt = _buildPrompt(title, content, url, imageUrl);
      final response = await _callOpenRouterAPI(prompt);
      return _parseAIResponse(response);
    } catch (e) {
      print('AI Analysis failed: $e');
      return _fallbackAnalysis(title, content);
    }
  }

  String _buildPrompt(String title, String content, String? url, String? imageUrl) {
    return '''You are an expert fact-checker and misinformation analyst. Analyze this news article with EXTREME SCRUTINY for fake news indicators.

CRITICAL ANALYSIS GUIDELINES:
- Be HIGHLY SUSPICIOUS of sensational claims without credible sources
- MAJOR RED FLAG: Claims about disasters, deaths, or shocking events without named sources
- MAJOR RED FLAG: Vague phrases like "more than X died" without specific attribution
- MAJOR RED FLAG: Emotional manipulation or fear-mongering language
- MAJOR RED FLAG: Lack of verifiable sources, dates, or official statements
- MAJOR RED FLAG: Clickbait headlines that don't match content
- Look for: Who, What, When, Where, Why with SPECIFIC details
- Verify: Are there named officials, organizations, or credible news outlets cited?
- Check: Does the article provide verifiable facts or just claims?

ARTICLE TO ANALYZE:
Title: "$title"
Content: "$content"
${url != null ? 'Source URL: $url' : ''}
${imageUrl != null ? 'Image URL: $imageUrl' : ''}

RESPOND IN THIS EXACT JSON FORMAT (no markdown, no code blocks, just raw JSON):
{
  "isFake": true/false,
  "confidence": 0.0-1.0,
  "reasoning": "Detailed explanation of your analysis focusing on credibility indicators",
  "redFlags": ["specific issue 1", "specific issue 2", ...],
  "sources": ["credible source 1", "credible source 2", ...] or ["No credible sources identified"]
}

IMPORTANT RULES:
1. If there are NO named sources, officials, or organizations → HIGH chance of fake news
2. If claims are vague or unverifiable → Mark as suspicious
3. If emotional/sensational language without facts → RED FLAG
4. If no specific dates, locations, or verifiable details → RED FLAG
5. Confidence should be HIGH (>0.80) when multiple red flags present
6. Be STRICT - better to flag suspicious content than miss fake news

Analyze now and respond ONLY with the JSON object:''';
  }

  Future<String> _callOpenRouterAPI(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://github.com/ashu13579/fake-news-detector-flutter',
        'X-Title': 'Fake News Detector',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.3, // Lower temperature for more consistent analysis
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];
    return content;
  }

  VerificationResult _parseAIResponse(String response) {
    try {
      // Clean the response - remove markdown code blocks if present
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      final json = jsonDecode(cleanedResponse);
      
      return VerificationResult(
        isFake: json['isFake'] ?? false,
        confidence: (json['confidence'] ?? 0.5).toDouble(),
        reasoning: json['reasoning'] ?? 'Analysis completed',
        redFlags: List<String>.from(json['redFlags'] ?? []),
        sources: List<String>.from(json['sources'] ?? ['No sources identified']),
      );
    } catch (e) {
      print('Failed to parse AI response: $e');
      print('Response was: $response');
      // Return a cautious result if parsing fails
      return VerificationResult(
        isFake: true,
        confidence: 0.6,
        reasoning: 'Unable to complete full analysis. Please verify with trusted sources.',
        redFlags: ['Analysis parsing error - manual verification recommended'],
        sources: ['No sources identified'],
      );
    }
  }

  VerificationResult _fallbackAnalysis(String title, String content) {
    final combinedText = '$title $content'.toLowerCase();
    final redFlags = <String>[];
    int suspicionScore = 0;

    // Check for sensational language
    final sensationalWords = [
      'shocking', 'unbelievable', 'you won\'t believe',
      'breaking', 'urgent', 'alert', 'warning',
      'miracle', 'secret', 'exposed', 'revealed'
    ];
    
    for (final word in sensationalWords) {
      if (combinedText.contains(word)) {
        redFlags.add('Sensational language detected: "$word"');
        suspicionScore += 15;
      }
    }

    // Check for lack of sources
    final sourceIndicators = [
      'according to', 'reported by', 'study shows',
      'research', 'official', 'spokesperson'
    ];
    
    bool hasSources = false;
    for (final indicator in sourceIndicators) {
      if (combinedText.contains(indicator)) {
        hasSources = true;
        break;
      }
    }
    
    if (!hasSources) {
      redFlags.add('No credible sources cited');
      suspicionScore += 25;
    }

    // Check for excessive punctuation
    if (RegExp(r'[!?]{2,}').hasMatch(combinedText)) {
      redFlags.add('Excessive punctuation detected');
      suspicionScore += 10;
    }

    // Check for all caps
    if (RegExp(r'[A-Z]{5,}').hasMatch(title)) {
      redFlags.add('Excessive capitalization in title');
      suspicionScore += 10;
    }

    // Check for emotional manipulation
    final emotionalWords = [
      'outrage', 'fury', 'panic', 'fear', 'terror',
      'disaster', 'catastrophe', 'crisis'
    ];
    
    for (final word in emotionalWords) {
      if (combinedText.contains(word)) {
        redFlags.add('Emotional manipulation detected');
        suspicionScore += 10;
        break;
      }
    }

    // Calculate confidence and verdict
    final confidence = (suspicionScore / 100).clamp(0.0, 1.0);
    final isFake = suspicionScore >= 40;

    return VerificationResult(
      isFake: isFake,
      confidence: confidence,
      reasoning: isFake
          ? 'This article shows multiple indicators of potential misinformation. '
              'It lacks credible sources and uses sensational language. '
              'Please verify with trusted news sources.'
          : 'This article appears to follow journalistic standards with proper sourcing. '
              'However, always cross-reference important information with multiple trusted sources.',
      redFlags: redFlags.isEmpty ? ['No major red flags detected'] : redFlags,
      sources: hasSources
          ? ['Article cites sources']
          : ['No sources identified'],
    );
  }
}
