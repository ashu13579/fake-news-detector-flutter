import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class FakeNewsDetectorService {
  // Using Google AI Studio API directly - more reliable and free
  // Using gemini-2.5-flash (current stable model as of Jan 2026)
  // 1.5 models were retired in 2025, 2.5 is the current series
  // Free tier: 15 RPM, 1000 RPD, 1M token context
  // Supports multimodal input (text + images)
  static const String _model = 'gemini-2.5-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
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
      final response = await _callGeminiAPI(prompt, imageUrl: imageUrl);
      return _parseAIResponse(response);
    } catch (e) {
      print('AI Analysis failed: $e');
      return _fallbackAnalysis(title, content);
    }
  }

  String _buildPrompt(String title, String content, String? url, String? imageUrl) {
    final combinedContent = '$title\n\n$content';
    
    String imageContext = '';
    if (imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        imageContext = '\n\nIMAGE PROVIDED: A local image has been uploaded for analysis. Please analyze the image for signs of manipulation, deepfakes, misleading context, or fake news indicators.';
      } else {
        imageContext = '\n\nImage URL: $imageUrl\nPlease consider the image in your analysis if it provides relevant context.';
      }
    }
    
    return '''You are an expert fact-checker and fake news detection AI with image analysis capabilities. Your task is to analyze the provided content (text and/or images) and determine if it is likely to be real news or fake news.

Analyze based on these criteria:
1. Source credibility - Does the content come from or cite reputable sources?
2. Language analysis - Check for sensationalist language, excessive capitalization, or emotional manipulation
3. Factual consistency - Are there logical inconsistencies or implausible claims?
4. Bias indicators - Is there obvious political or ideological bias?
5. Verification signals - Are there verifiable facts, dates, names, and places?
${imageUrl != null ? '6. Image analysis - Check for signs of manipulation, deepfakes, misleading context, or visual misinformation' : ''}

CONTENT TO ANALYZE:
$combinedContent
${url != null ? '\nSource URL: $url' : ''}$imageContext

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
${imageUrl != null ? '- If analyzing an image, check for visual manipulation, deepfakes, misleading captions, or out-of-context usage' : ''}

Analyze now and respond ONLY with the JSON object:''';
  }

  Future<String> _callGeminiAPI(String prompt, {String? imageUrl}) async {
    final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
    
    // Build the request body with multimodal support
    Map<String, dynamic> requestBody;
    
    if (imageUrl != null && imageUrl.startsWith('data:image')) {
      // Extract base64 data from data URL
      final base64Data = imageUrl.split(',')[1];
      final mimeType = imageUrl.split(';')[0].split(':')[1]; // e.g., "image/jpeg"
      
      requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Data,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 2048,
        }
      };
    } else {
      // Text-only request
      requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 2048,
        }
      };
    }
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    
    // Extract text from Gemini API response format
    if (data['candidates'] == null || data['candidates'].isEmpty) {
      throw Exception('No response from Gemini API');
    }
    
    final content = data['candidates'][0]['content']['parts'][0]['text'];
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
