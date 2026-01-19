import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class FakeNewsDetectorService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  // Using Meta Llama 3.1 8B (free) - more stable than Gemini free tier
  static const String _model = 'meta-llama/llama-3.1-8b-instruct:free';
  
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
    final combinedContent = '$title\n\n$content';
    
    return '''You are an expert fact-checker and fake news detection AI. Your task is to analyze the provided content and determine if it is likely to be real news or fake news.

Analyze based on these criteria:
1. Source credibility - Does the content come from or cite reputable sources?
2. Language analysis - Check for sensationalist language, excessive capitalization, or emotional manipulation
3. Factual consistency - Are there logical inconsistencies or implausible claims?
4. Bias indicators - Is there obvious political or ideological bias?
5. Verification signals - Are there verifiable facts, dates, names, and places?

CONTENT TO ANALYZE:
$combinedContent
${url != null ? '\nSource URL: $url' : ''}
${imageUrl != null ? '\nImage URL: $imageUrl' : ''}

You MUST respond with ONLY a valid JSON object in this exact format (no markdown, no code blocks):
{
  "verdict": "REAL" or "FAKE" or "UNCERTAIN",
  "confidence": number between 0 and 100,
  "analysis": {
    "sourceCredibility": "brief assessment",
    "languageQuality": "brief assessment",
    "factualConsistency": "brief assessment",
    "biasIndicators": "brief assessment",
    "verificationStatus": "brief assessment"
  },
  "summary": "2-3 sentence overall summary",
  "redFlags": ["list of concerning elements if any"],
  "recommendations": ["suggested actions for verification"]
}

IMPORTANT GUIDELINES:
- Use "REAL" for content that appears legitimate with credible sources
- Use "FAKE" for content with clear misinformation indicators
- Use "UNCERTAIN" when there's insufficient evidence or mixed signals
- Confidence should reflect how sure you are (0-100)
- Be thorough but concise in your analysis
- List specific red flags if found
- Provide actionable recommendations

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
        'temperature': 0.3,
        'max_tokens': 1500,
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

      // Extract JSON from the response (handle potential markdown code blocks)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedResponse);
      if (jsonMatch == null) {
        throw Exception('No JSON found in response');
      }

      final json = jsonDecode(jsonMatch.group(0)!);
      
      // Parse verdict to isFake boolean
      final verdict = json['verdict'] as String;
      final isFake = verdict.toUpperCase() == 'FAKE';
      
      // Convert confidence from 0-100 to 0-1
      final confidence = (json['confidence'] as num).toDouble() / 100.0;
      
      // Parse detailed analysis
      DetailedAnalysis? detailedAnalysis;
      if (json['analysis'] != null) {
        detailedAnalysis = DetailedAnalysis.fromJson(json['analysis']);
      }
      
      return VerificationResult(
        isFake: isFake,
        confidence: confidence,
        reasoning: json['summary'] ?? 'Analysis completed',
        redFlags: List<String>.from(json['redFlags'] ?? []),
        sources: [], // Not used in new format
        detailedAnalysis: detailedAnalysis,
        summary: json['summary'],
        recommendations: json['recommendations'] != null 
            ? List<String>.from(json['recommendations'])
            : null,
      );
    } catch (e) {
      print('Failed to parse AI response: $e');
      print('Response was: $response');
      
      // Return uncertain result if parsing fails
      return VerificationResult(
        isFake: false,
        confidence: 0.3, // Low confidence = uncertain
        reasoning: 'Unable to complete full analysis. The response format was unexpected.',
        redFlags: ['Analysis parsing error - manual verification recommended'],
        sources: [],
        detailedAnalysis: DetailedAnalysis(
          sourceCredibility: 'Unable to analyze',
          languageQuality: 'Unable to analyze',
          factualConsistency: 'Unable to analyze',
          biasIndicators: 'Unable to analyze',
          verificationStatus: 'Pending manual verification',
        ),
        summary: 'Unable to complete full analysis. Please verify with trusted sources.',
        recommendations: [
          'Verify with established fact-checking websites',
          'Cross-reference with multiple sources',
          'Check the original source directly',
        ],
      );
    }
  }

  VerificationResult _fallbackAnalysis(String title, String content) {
    final combinedText = '$title $content'.toLowerCase();
    final redFlags = <String>[];
    final recommendations = <String>[];
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

    // Generate recommendations
    recommendations.addAll([
      'Verify with established fact-checking websites',
      'Cross-reference with multiple trusted news sources',
      'Check the original source and publication date',
    ]);

    if (!hasSources) {
      recommendations.add('Look for articles with named sources and citations');
    }

    return VerificationResult(
      isFake: isFake,
      confidence: confidence,
      reasoning: isFake
          ? 'This article shows multiple indicators of potential misinformation. '
              'It lacks credible sources and uses sensational language.'
          : 'This article appears to follow basic journalistic standards.',
      redFlags: redFlags.isEmpty ? [] : redFlags,
      sources: [],
      detailedAnalysis: DetailedAnalysis(
        sourceCredibility: hasSources 
            ? 'Article cites some sources' 
            : 'No credible sources identified',
        languageQuality: suspicionScore > 30 
            ? 'Contains sensational or emotional language' 
            : 'Language appears neutral',
        factualConsistency: 'Unable to verify without external sources',
        biasIndicators: suspicionScore > 20 
            ? 'Potential bias detected' 
            : 'No obvious bias detected',
        verificationStatus: 'Requires manual verification',
      ),
      summary: isFake
          ? 'This article shows multiple indicators of potential misinformation. Please verify with trusted sources.'
          : 'This article appears to follow basic journalistic standards. However, always cross-reference important information.',
      recommendations: recommendations,
    );
  }
}
