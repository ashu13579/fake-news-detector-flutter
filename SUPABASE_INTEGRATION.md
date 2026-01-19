# Supabase Edge Function Integration Guide

This guide explains how to integrate the Supabase edge function for fake news detection into your Flutter app.

## 📋 Overview

The app now supports **two analysis backends**:

1. **OpenRouter AI** (existing) - Direct API calls using your OpenRouter API key
2. **Supabase Edge Functions** (new) - Serverless functions using Lovable AI Gateway

## 🏗️ Architecture

```
Flutter App
    ↓
SupabaseNewsService
    ↓
Supabase Edge Function (analyze-news)
    ↓
Lovable AI Gateway
    ↓
Google Gemini 2.5 Flash
```

## 📁 Files Added/Modified

### New Files
- `lib/services/supabase_news_service.dart` - Supabase integration service
- `SUPABASE_INTEGRATION.md` - This guide

### Modified Files
- `lib/models/news_article.dart` - Added detailed analysis structure
- `lib/widgets/result_card.dart` - Enhanced UI with detailed analysis display
- `lib/widgets/analysis_result_card.dart` - Updated to use verdict system

## 🔧 Setup Instructions

### 1. Deploy Supabase Edge Function

Create a new edge function in your Supabase project:

```bash
# In your Supabase project
supabase functions new analyze-news
```

Copy the edge function code from the beginning of this conversation into:
```
supabase/functions/analyze-news/index.ts
```

Deploy the function:
```bash
supabase functions deploy analyze-news
```

### 2. Set Environment Variables

In your Supabase dashboard, set the `LOVABLE_API_KEY` secret:

```bash
supabase secrets set LOVABLE_API_KEY=your_lovable_api_key_here
```

### 3. Configure Flutter App

Add Supabase credentials to your app. Create a config file or use environment variables:

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### 4. Update Dependencies

Ensure you have the required packages in `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  flutter_animate: ^4.3.0
  cached_network_image: ^3.3.0
  url_launcher: ^6.2.2
```

## 💻 Usage Examples

### Using Supabase Service

```dart
import 'package:fake_news_detector/services/supabase_news_service.dart';
import 'package:fake_news_detector/config/supabase_config.dart';

// Initialize service
final supabaseService = SupabaseNewsService(
  supabaseUrl: SupabaseConfig.supabaseUrl,
  supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
);

// Analyze text
try {
  final result = await supabaseService.analyzeText(
    content: 'News article text here...',
  );
  
  print('Verdict: ${result.verdictLabel}');
  print('Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%');
  
  if (result.detailedAnalysis != null) {
    print('Source Credibility: ${result.detailedAnalysis!.sourceCredibility}');
    print('Language Quality: ${result.detailedAnalysis!.languageQuality}');
  }
  
  if (result.recommendations != null) {
    print('Recommendations:');
    for (var rec in result.recommendations!) {
      print('  - $rec');
    }
  }
} catch (e) {
  print('Analysis failed: $e');
}
```

### Analyze URL

```dart
final result = await supabaseService.analyzeUrl(
  url: 'https://example.com/news-article',
);
```

### Analyze Image

```dart
import 'dart:convert';
import 'dart:io';

// Convert image to base64
final imageFile = File('path/to/image.jpg');
final bytes = await imageFile.readAsBytes();
final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

final result = await supabaseService.analyzeImage(
  imageBase64: base64Image,
);
```

## 📊 Response Structure

### Supabase Edge Function Response

```json
{
  "success": true,
  "result": {
    "verdict": "REAL" | "FAKE" | "UNCERTAIN",
    "confidence": 0-100,
    "analysis": {
      "sourceCredibility": "Assessment of source reliability",
      "languageQuality": "Analysis of writing quality",
      "factualConsistency": "Logical consistency check",
      "biasIndicators": "Political/ideological bias detection",
      "verificationStatus": "Verification signal assessment"
    },
    "summary": "2-3 sentence overall summary",
    "redFlags": ["List of concerning elements"],
    "recommendations": ["Suggested verification actions"]
  }
}
```

### Flutter Model Mapping

The `VerificationResult.fromSupabaseResponse()` factory converts this to:

```dart
VerificationResult(
  isFake: verdict == 'FAKE',
  confidence: confidence / 100.0,  // Convert 0-100 to 0-1
  reasoning: summary,
  redFlags: redFlags,
  sources: [],
  detailedAnalysis: DetailedAnalysis(...),
  summary: summary,
  recommendations: recommendations,
)
```

## 🎨 UI Features

### Result Card Enhancements

The updated `ResultCard` widget now displays:

1. **Main Verdict** - Color-coded header with icon
2. **Confidence Bar** - Visual progress indicator
3. **Summary** - AI-generated analysis summary
4. **Red Flags** - List of concerning elements
5. **Expandable Detailed Analysis** - 5 analysis categories:
   - Source Credibility
   - Language Quality
   - Factual Consistency
   - Bias Indicators
   - Verification Status
6. **Recommendations** - Actionable verification steps

### Verdict Classification

| Verdict | Confidence | Color | Icon |
|---------|-----------|-------|------|
| **Fake** | ≥ 50% + isFake=true | 🔴 Red | ⚠️ Warning |
| **Real** | ≥ 50% + isFake=false | 🔵 Blue | ✓ Check |
| **Uncertain** | < 50% | 🟠 Orange | ❓ Question |

## 🔄 Migration from OpenRouter

To switch from OpenRouter to Supabase:

### Before (OpenRouter)
```dart
final service = FakeNewsDetectorService();
service.setApiKey('your-openrouter-key');

final result = await service.analyzeNews(
  title,
  content,
  url: url,
  imageUrl: imageUrl,
);
```

### After (Supabase)
```dart
final service = SupabaseNewsService(
  supabaseUrl: SupabaseConfig.supabaseUrl,
  supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
);

final result = await service.analyzeText(
  content: '$title\n\n$content',
);
```

## 🚨 Error Handling

The service handles common errors:

```dart
try {
  final result = await supabaseService.analyzeText(content: text);
} catch (e) {
  if (e.toString().contains('Rate limit exceeded')) {
    // Show rate limit message
  } else if (e.toString().contains('Usage limit reached')) {
    // Show usage limit message
  } else {
    // Show generic error
  }
}
```

## 🔐 Security Best Practices

1. **Never commit API keys** - Use environment variables
2. **Use Supabase RLS** - Implement Row Level Security policies
3. **Rate limiting** - The edge function already handles this
4. **Input validation** - Validate content before sending

## 📈 Performance Considerations

- **Edge function cold starts**: ~1-2 seconds on first call
- **Warm function**: ~500ms-1s response time
- **Rate limits**: Configured in Lovable AI Gateway
- **Caching**: Consider caching results for identical content

## 🧪 Testing

### Test the Edge Function

```bash
curl -X POST https://your-project.supabase.co/functions/v1/analyze-news \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "text",
    "content": "Breaking news: Scientists discover new planet!"
  }'
```

### Test in Flutter

```dart
void testSupabaseIntegration() async {
  final service = SupabaseNewsService(
    supabaseUrl: 'https://your-project.supabase.co',
    supabaseAnonKey: 'your-anon-key',
  );

  final testCases = [
    'Legitimate news with sources',
    'SHOCKING!!! You won\'t believe this!!!',
    'Scientists at MIT published a study showing...',
  ];

  for (var content in testCases) {
    try {
      final result = await service.analyzeText(content: content);
      print('Content: $content');
      print('Verdict: ${result.verdictLabel}');
      print('Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%');
      print('---');
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

## 🎯 Next Steps

1. ✅ Deploy Supabase edge function
2. ✅ Configure environment variables
3. ✅ Update Flutter app configuration
4. ✅ Test integration
5. 🔄 Migrate existing code (optional)
6. 📊 Monitor usage and performance
7. 🎨 Customize UI based on feedback

## 📚 Additional Resources

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Lovable AI Gateway](https://ai.gateway.lovable.dev)
- [Flutter HTTP Package](https://pub.dev/packages/http)

## 🐛 Troubleshooting

### Common Issues

**Issue**: "LOVABLE_API_KEY is not configured"
- **Solution**: Set the secret in Supabase dashboard

**Issue**: Rate limit errors
- **Solution**: Implement exponential backoff or caching

**Issue**: CORS errors
- **Solution**: Edge function already includes CORS headers

**Issue**: Parsing errors
- **Solution**: Check edge function logs in Supabase dashboard

## 💡 Tips

1. **Use Supabase for production** - Better rate limits and reliability
2. **Keep OpenRouter as fallback** - Redundancy is good
3. **Cache results** - Avoid re-analyzing identical content
4. **Monitor costs** - Track Lovable AI Gateway usage
5. **A/B test** - Compare accuracy between backends

---

**Need help?** Check the Supabase logs or create an issue in the repository.
