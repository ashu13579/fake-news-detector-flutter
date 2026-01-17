# Fake News Detector - Flutter App

A Flutter application that helps users identify potentially fake news articles using AI-powered analysis. The app analyzes article titles and content to detect common indicators of misinformation.

## Features

- 📰 **Article Analysis**: Paste news article titles and content for instant analysis
- 🔍 **AI-Powered Detection**: Uses multiple indicators to identify fake news patterns
- 📊 **Confidence Scoring**: Get a confidence percentage for each analysis
- 🚩 **Red Flag Detection**: Identifies specific problematic elements in articles
- 📚 **Analysis History**: Keep track of all analyzed articles
- 🎨 **Modern UI**: Clean, Material Design 3 interface with dark mode support
- 🔗 **Source Linking**: Add and access article URLs directly

## How It Works

The app analyzes news articles based on several criteria:

1. **Sensational Language**: Detects clickbait and exaggerated claims
2. **Source Credibility**: Checks for proper citations and references
3. **Emotional Manipulation**: Identifies attempts to trigger emotional responses
4. **Formatting Red Flags**: Spots excessive punctuation and ALL CAPS titles
5. **Content Quality**: Evaluates overall article structure and credibility

## Screenshots

[Add screenshots here]

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/ashu13579/fake-news-detector-flutter.git
cd fake-news-detector-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. **Analyze an Article**:
   - Navigate to the "Analyze" tab
   - Enter the article title
   - Paste the article content (minimum 50 characters)
   - Optionally add the source URL
   - Tap "Analyze Article"

2. **View Results**:
   - Check the confidence score
   - Review identified red flags
   - Read the detailed reasoning
   - See credible sources (if any)

3. **Manage History**:
   - Switch to the "History" tab
   - View all analyzed articles
   - Delete individual entries
   - Clear entire history

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── news_article.dart             # Data models
├── providers/
│   └── news_provider.dart            # State management
├── screens/
│   └── home_screen.dart              # Main screen
├── services/
│   └── fake_news_detector_service.dart # Analysis logic
└── widgets/
    ├── analysis_history.dart         # History view
    ├── news_input_form.dart          # Input form
    └── result_card.dart              # Result display
```

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **Material Design 3**: Modern UI components
- **url_launcher**: Open article links
- **shared_preferences**: Local data persistence

## Future Enhancements

- [ ] Integration with real ML/AI API for more accurate detection
- [ ] Fact-checking database integration
- [ ] Share analysis results
- [ ] Multi-language support
- [ ] Browser extension version
- [ ] Real-time news feed analysis
- [ ] User accounts and cloud sync

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Disclaimer

This app provides analysis based on common fake news indicators. It should be used as a tool to encourage critical thinking, not as the sole source of truth. Always verify important information with multiple trusted sources.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**ASHUTOSH YADAV**
- Email: 23053934@kiit.ac.in
- GitHub: [@ashu13579](https://github.com/ashu13579)

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for inspiration

---

Made with ❤️ using Flutter
