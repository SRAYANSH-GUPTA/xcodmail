# ColdMail - AI-Powered Cold Outreach Email Generator

A privacy-focused Flutter app that generates personalized cold outreach emails using Gemini API. Upload a PDF document and let AI create compelling, personalized cold emails for your business outreach.

## Features

- 📄 **PDF Upload**: Upload PDF documents containing client/company information
- 🤖 **AI-Powered Analysis**: Uses Google's Gemini API to analyze PDF content
- ✉️ **Personalized Emails**: Generates tailored cold outreach emails based on PDF content
- 🔍 **Key Information Extraction**: Automatically extracts relevant business information
- 📧 **Gmail Integration**: Direct integration with Gmail for easy email composition
- 🎨 **Modern UI**: Beautiful, intuitive interface with Material Design 3
- 🔒 **Privacy Focused**: Your data stays private and secure

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Gemini API Key

### 2. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the API key for the next step

### 3. Configure Environment Variables

1. Create a `.env` file in the root directory of the project
2. Add your Gemini API key:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

**Important**: Never commit your `.env` file to version control. It's already added to `.gitignore`.

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the Application

```bash
flutter run
```

## How to Use

1. **Upload PDF**: Tap the upload area to select a PDF file containing information about your target client or company
2. **AI Analysis**: The app will automatically analyze the PDF and extract key information
3. **Email Generation**: AI generates a personalized cold outreach email based on the PDF content
4. **Review & Send**: Review the generated email and click "Open in Gmail" to compose and send

## Project Structure

```
lib/
├── core/                 # Core utilities and constants
├── data/
│   ├── datasources/      # Data sources and API clients
│   ├── models/          # Data models
│   └── services/        # Business logic services
│       ├── pdf_service.dart      # PDF text extraction
│       └── gemini_service.dart   # Gemini API integration
├── di/                  # Dependency injection
├── domain/
│   ├── entities/        # Domain entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/       # Business use cases
└── presentation/
    ├── providers/       # State management
    ├── screens/         # UI screens
    │   └── pdf_upload_screen.dart
    └── widgets/         # Reusable UI components
```

## Dependencies

- **flutter_riverpod**: State management
- **get_it**: Dependency injection
- **flutter_dotenv**: Environment variable management
- **http**: HTTP client for API calls
- **syncfusion_flutter_pdf**: PDF text extraction
- **file_picker**: File selection
- **url_launcher**: Gmail integration
- **google_fonts**: Typography

## Privacy & Security

- All PDF processing happens locally on your device
- Only the PDF content is sent to Gemini API for analysis
- No data is stored or logged on external servers
- Your API key is kept secure in local environment variables

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

**Note**: Make sure to replace `your_actual_api_key_here` with your real Gemini API key in the `.env` file.
