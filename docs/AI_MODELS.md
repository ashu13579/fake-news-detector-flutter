# AI Models & Rate Limit Solutions

## 🚨 Current Issue: Rate Limiting

The free Google Gemini model (`google/gemini-2.0-flash-exp:free`) can get rate-limited during high usage periods.

**Error Message:**
```
google/gemini-2.0-flash-exp:free is temporarily rate-limited upstream. 
Please retry shortly, or add your own key to accumulate your rate limits
```

## ✅ Solution Applied

**Changed to:** `meta-llama/llama-3.1-8b-instruct:free`

This model is:
- ✅ More stable (less rate-limited)
- ✅ Still completely free
- ✅ Good at structured JSON responses
- ✅ Fast response times

## 🔄 Alternative Free Models

If you encounter rate limits again, try these alternatives in `lib/services/fake_news_detector_service.dart`:

### Option 1: Meta Llama 3.1 8B (Current)
```dart
static const String _model = 'meta-llama/llama-3.1-8b-instruct:free';
```
- **Best for:** Structured analysis, JSON responses
- **Speed:** Fast
- **Rate limits:** Low

### Option 2: Meta Llama 3.2 3B
```dart
static const String _model = 'meta-llama/llama-3.2-3b-instruct:free';
```
- **Best for:** Quick analysis, lower resource usage
- **Speed:** Very fast
- **Rate limits:** Very low

### Option 3: Google Gemini Flash 1.5
```dart
static const String _model = 'google/gemini-flash-1.5:free';
```
- **Best for:** Detailed analysis
- **Speed:** Fast
- **Rate limits:** Medium

### Option 4: Mistral 7B
```dart
static const String _model = 'mistralai/mistral-7b-instruct:free';
```
- **Best for:** Balanced performance
- **Speed:** Fast
- **Rate limits:** Low

### Option 5: Qwen 2.5 7B
```dart
static const String _model = 'qwen/qwen-2.5-7b-instruct:free';
```
- **Best for:** Multilingual support
- **Speed:** Fast
- **Rate limits:** Low

## 💰 Paid Models (Better Performance)

If you need guaranteed uptime and better accuracy, consider these paid models:

### Premium Option 1: GPT-4 Turbo
```dart
static const String _model = 'openai/gpt-4-turbo';
```
- **Cost:** ~$0.01 per analysis
- **Best for:** Highest accuracy
- **Speed:** Medium

### Premium Option 2: Claude 3.5 Sonnet
```dart
static const String _model = 'anthropic/claude-3.5-sonnet';
```
- **Cost:** ~$0.003 per analysis
- **Best for:** Nuanced analysis
- **Speed:** Fast

### Premium Option 3: Gemini Pro 1.5
```dart
static const String _model = 'google/gemini-pro-1.5';
```
- **Cost:** ~$0.001 per analysis
- **Best for:** Cost-effective premium
- **Speed:** Very fast

## 🔧 How to Change Models

1. Open `lib/services/fake_news_detector_service.dart`
2. Find line 7:
   ```dart
   static const String _model = 'meta-llama/llama-3.1-8b-instruct:free';
   ```
3. Replace with your chosen model
4. Save and restart the app

## 📊 Model Comparison

| Model | Speed | Accuracy | Rate Limits | Cost |
|-------|-------|----------|-------------|------|
| **Llama 3.1 8B** ⭐ | ⚡⚡⚡ | ⭐⭐⭐⭐ | ✅ Low | Free |
| Llama 3.2 3B | ⚡⚡⚡⚡ | ⭐⭐⭐ | ✅ Very Low | Free |
| Gemini Flash 1.5 | ⚡⚡⚡ | ⭐⭐⭐⭐ | ⚠️ Medium | Free |
| Gemini 2.0 Flash | ⚡⚡⚡⚡ | ⭐⭐⭐⭐⭐ | ❌ High | Free |
| Mistral 7B | ⚡⚡⚡ | ⭐⭐⭐⭐ | ✅ Low | Free |
| GPT-4 Turbo | ⚡⚡ | ⭐⭐⭐⭐⭐ | ✅ None | $$$ |
| Claude 3.5 | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | ✅ None | $$ |

⭐ = Current recommendation

## 🛠️ Troubleshooting Rate Limits

### If you still get rate limited:

1. **Wait 1-2 minutes** - Rate limits are temporary
2. **Switch models** - Use one of the alternatives above
3. **Add retry logic** - The app already falls back to local analysis
4. **Use paid model** - Guaranteed no rate limits

### Check OpenRouter Status

Visit: https://openrouter.ai/models

- Green = Available
- Yellow = Degraded
- Red = Rate limited

## 💡 Best Practices

1. **Start with free models** - They work well for most cases
2. **Monitor usage** - Check OpenRouter dashboard
3. **Have a backup** - The app has fallback analysis built-in
4. **Consider paid for production** - More reliable for high traffic

## 🔐 API Key Management

Your OpenRouter API key is stored locally in the app. To get better rate limits:

1. Create account at https://openrouter.ai
2. Add credits (optional, for paid models)
3. Generate API key
4. Enter in app settings

**Free tier limits:**
- ~10-20 requests per minute
- Shared across all free users
- Resets every minute

**Paid tier benefits:**
- Higher rate limits
- Priority access
- Better models
- No shared limits

## 📈 Performance Tips

1. **Cache results** - Don't re-analyze the same content
2. **Batch requests** - Wait between analyses
3. **Use appropriate model** - Don't use GPT-4 for simple checks
4. **Monitor costs** - Set up billing alerts

## 🆘 Need Help?

- OpenRouter Docs: https://openrouter.ai/docs
- Model Pricing: https://openrouter.ai/models
- Status Page: https://status.openrouter.ai

---

**Last Updated:** January 19, 2026  
**Current Model:** `meta-llama/llama-3.1-8b-instruct:free`
