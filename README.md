# 🛡️ Fake News Detector - Flutter App

A modern Flutter application that uses **AI-powered analysis** to help users identify potentially fake news articles. Built with Google's **Gemini 2.0 Flash** model via OpenRouter API.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![AI](https://img.shields.io/badge/AI-Gemini%202.0-orange.svg)

## ✨ Features

### 🤖 AI-Powered Analysis
- **Real AI Detection**: Uses Google's Gemini 2.0 Flash model via OpenRouter
- **Text Analysis**: Analyzes article titles and content for authenticity
- **Image Support**: Upload images or provide URLs for visual context analysis
- **Confidence Scoring**: Get percentage-based confidence ratings
- **Detailed Reasoning**: Understand why content is flagged

### 🎨 Modern UI/UX
- **Material Design 3**: Latest design system with dynamic theming
- **Glassmorphism Effects**: Beautiful frosted glass UI elements
- **Smooth Animations**: Flutter Animate for delightful interactions
- **Google Fonts**: Professional typography with Inter font family
- **Dark Mode**: Full dark theme support
- **Gradient Backgrounds**: Eye-catching color schemes

### 📱 Core Functionality
- **Multi-Input Support**: Text, URLs, and images
- **Analysis History**: Track all your fact-checks
- **Red Flag Detection**: Identifies specific problematic elements
- **Source Verification**: Checks for credible citations
- **Offline Fallback**: Basic analysis when API is unavailable

## 🧠 AI Model Information

### Primary Model
- **Model**: Google Gemini 2.0 Flash Experimental
- **Provider**: OpenRouter API
- **Endpoint**: `google/gemini-2.0-flash-exp:free`
- **Location**: `lib/services/fake_news_detector_service.dart`

### Analysis Capabilities
1. **Sensational Language Detection**: Identifies clickbait and exaggerated claims
2. **Source Credibility**: Checks for proper citations and references
3. **Emotional Manipulation**: Detects attempts to trigger emotional responses
4. **Formatting Analysis**: Spots excessive punctuation and ALL CAPS
5. **Image-Text Consistency**: Verifies if images match article content (when image provided)
6. **Content Quality**: Evaluates overall article structure and professionalism

### Fallback System
If no API key is configured, the app uses a local rule-based analysis system that checks for:
- Sensational keywords
- Formatting red flags
- Source indicators
- Emotional manipulation patterns

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- OpenRouter API key (free at [openrouter.ai](https://openrouter.ai))

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/ashu13579/fake-news-detector-flutter.git
cd fake-news-detector-flutter
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
flutter run
```

### Setting Up AI Analysis

1. **Get an OpenRouter API Key**:
   - Visit [openrouter.ai](https://openrouter.ai)
   - Sign up or log in
   - Navigate to the Keys section
   - Create a new API key
   - Copy the key (starts with `sk-or-v1-...`)

2. **Add API Key in App**:
   - Open the app
   - Tap the settings icon (⚙️) in the top right
   - Paste your API key
   - Tap "Save Key"
   - You're ready to use AI analysis!

## 📱 Usage

### Analyzing an Article

1. **Navigate to Analyze Tab**:
   - Enter the article title
   - Paste the article content (minimum 50 characters)
   - Optionally add source URL
   - Optionally upload an image or provide image URL

2. **Run Analysis**:
   - Tap "Analyze Article"
   - Wait for AI processing (2-5 seconds)
   - View results in the History tab

3. **Understanding Results**:
   - **Green Badge**: Appears legitimate
   - **Red Badge**: Likely fake news
   - **Confidence Score**: Percentage of certainty
   - **Red Flags**: Specific issues found
   - **Sources**: Credible citations identified

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point with theme
├── models/
│   └── news_article.dart             # Data models (Article & Result)
├── providers/
│   └── news_provider.dart            # State management
├── screens/
│   └── home_screen.dart              # Main screen with navigation
├── services/
│   └── fake_news_detector_service.dart # AI analysis logic ⭐
└── widgets/
    ├── analysis_history.dart         # History view
    ├── news_input_form.dart          # Input form with image support
    ├── result_card.dart              # Result display
    └── settings_sheet.dart           # API key configuration
```

## 🎨 UI Components

### Modern Design Elements
- **Glassmorphism Cards**: Frosted glass effect containers
- **Gradient Backgrounds**: Multi-color gradients
- **Animated Transitions**: Smooth fade-ins and slides
- **Shimmer Effects**: Loading state animations
- **Rounded Corners**: 16-24px border radius throughout
- **Elevation Shadows**: Depth with colored shadows

### Dependencies
```yaml
dependencies:
  flutter_animate: ^4.3.0          # Smooth animations
  google_fonts: ^6.1.0             # Inter font family
  cached_network_image: ^3.3.0     # Image caching
  shimmer: ^3.0.0                  # Loading effects
  glassmorphism: ^3.0.0            # Glass UI
  image_picker: ^1.0.4             # Image upload
  provider: ^6.0.5                 # State management
  http: ^1.1.0                     # API calls
```

## 🔒 Privacy & Security

- **API Keys**: Stored locally, never shared
- **No Data Collection**: All analysis is private
- **No Server Storage**: Results stored only on device
- **Secure API Calls**: HTTPS encryption

## 🛠️ Customization

### Change AI Model
Edit `lib/services/fake_news_detector_service.dart`:
```dart
static const String _model = 'google/gemini-2.0-flash-exp:free';
// Change to any OpenRouter model
```

### Adjust Theme Colors
Edit `lib/main.dart`:
```dart
seedColor: const Color(0xFF6366F1), // Change primary color
```

## 📊 Future Enhancements

- [ ] Multi-language support
- [ ] Browser extension version
- [ ] Real-time news feed analysis
- [ ] Fact-checking database integration
- [ ] Share analysis results
- [ ] User accounts with cloud sync
- [ ] Advanced image analysis with OCR
- [ ] Video content analysis
- [ ] Social media integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ⚠️ Disclaimer

This app provides AI-powered analysis based on common fake news indicators. It should be used as a tool to encourage critical thinking, not as the sole source of truth. **Always verify important information with multiple trusted sources.**

The AI model may occasionally produce false positives or false negatives. Use your judgment and cross-reference with established fact-checking organizations.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**ASHUTOSH YADAV**
- Email: 23053934@kiit.ac.in
- GitHub: [@ashu13579](https://github.com/ashu13579)

## 🙏 Acknowledgments

- **Google** for Gemini AI model
- **OpenRouter** for API access
- **Flutter team** for the amazing framework
- **Material Design** team for design guidelines
- Open source community for inspiration

---

<div align="center">

Made with ❤️ using Flutter & AI

[Report Bug](https://github.com/ashu13579/fake-news-detector-flutter/issues) · [Request Feature](https://github.com/ashu13579/fake-news-detector-flutter/issues)

</div>
