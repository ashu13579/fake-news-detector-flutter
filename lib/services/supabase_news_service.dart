import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

/// Service for analyzing news using Supabase Edge Functions
/// This integrates with the analyze-news edge function that uses Lovable AI Gateway
class SupabaseNewsService {
  final String supabaseUrl;
  final String supabaseAnonKey;
  
  SupabaseNewsService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  /// Analyze news text content
  Future<VerificationResult> analyzeText({
    required String content,
  }) async {
    return _analyze(
      type: 'text',
      content: content,
    );
  }

  /// Analyze news from URL
  Future<VerificationResult> analyzeUrl({
    required String url,
  }) async {
    return _analyze(
      type: 'url',
      content: url,
    );
  }

  /// Analyze news from image (base64 encoded)
  Future<VerificationResult> analyzeImage({
    required String imageBase64,
  }) async {
    return _analyze(
      type: 'image',
      imageBase64: imageBase64,
    );
  }

  Future<VerificationResult> _analyze({
    required String type,
    String? content,
    String? imageBase64,
  }) async {
    try {
      final endpoint = '$supabaseUrl/functions/v1/analyze-news';
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'type': type,
          if (content != null) 'content': content,
          if (imageBase64 != null) 'imageBase64': imageBase64,
        }),
      );

      if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again in a moment.');
      }

      if (response.statusCode == 402) {
        throw Exception('Usage limit reached. Please try again later.');
      }

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      
      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      if (!data['success']) {
        throw Exception('Analysis failed');
      }

      // Parse the result using the Supabase response format
      return VerificationResult.fromSupabaseResponse(data['result']);
    } catch (e) {
      print('Supabase analysis failed: $e');
      rethrow;
    }
  }
}
