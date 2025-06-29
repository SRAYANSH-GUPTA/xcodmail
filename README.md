# ColdMail - AI-Powered Cold Email Generator

A privacy-focused Flutter app that generates personalized cold outreach emails using Gemini API. Upload your resume and let AI create compelling, tailored emails for your job applications.

## ✨ Features

### 🎯 **Enhanced Email Generation**
- **Company-Specific Targeting**: Enter company name and position for highly personalized emails
- **Two Template Types**:
  - **General**: Suitable for all companies with broad appeal
  - **Curated**: Specifically tailored with detailed company research and deep personalization
- **Technical Position Support**: Comprehensive dropdown with 40+ technical positions
- **Custom Position Input**: Add your own position if not in the predefined list

### 🤖 **AI-Powered Intelligence**
- **Company Research**: AI automatically researches target companies to understand their business, technology stack, recent news, and culture
- **Resume Analysis**: Extracts key information from your PDF resume including skills, experience, and achievements
- **Smart Personalization**: Creates compelling connections between your background and company needs
- **Professional Tone**: Generates confident, enthusiastic, and professional emails

### 💾 **Template Management**
- **Local Storage**: All templates are saved locally on your device for privacy
- **Template Library**: Access all your saved templates with company and position details
- **Filter by Type**: Filter templates by General or Curated type
- **Direct Gmail Integration**: One-click to open any template directly in Gmail
- **Template Deletion**: Remove individual templates or clear all at once

### 🔒 **Privacy & Security**
- **Local Storage**: All data stays on your device
- **No Cloud Storage**: Your resume and templates are never uploaded to external servers
- **Secure API Calls**: Only resume content is sent to Gemini API for analysis

### 📱 **User Experience**
- **Modern UI**: Beautiful, intuitive interface with Google Material Design
- **Real-time Validation**: Form validation ensures all required fields are completed
- **Loading States**: Clear feedback during PDF processing and email generation
- **Error Handling**: Comprehensive error messages and recovery options

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Gemini API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd coldmail
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your Gemini API key:
     ```
     GEMINI_API_KEY=your_api_key_here
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📖 How to Use

### 1. **Enter Job Details**
- **Company Name**: Enter the target company name
- **Position**: Select from 40+ technical positions or enter a custom position
- **Template Type**: Choose between General or Curated templates

### 2. **Upload Resume**
- Tap the upload area to select your PDF resume
- The app will process and analyze your resume

### 3. **Generate Email**
- Click "Generate Email" to create a personalized cold email
- The AI will research the company and tailor the email to your background

### 4. **Save & Use**
- **Copy Email**: Copy the generated content to clipboard
- **Open in Gmail**: Directly open the email in Gmail with pre-filled content
- **Save Template**: Save the template for future use

### 5. **Manage Templates**
- Access saved templates via the history icon in the app bar
- Filter templates by type (General/Curated)
- Open any template directly in Gmail
- Delete individual templates or clear all

## 🛠 Technical Stack

- **Framework**: Flutter 3.6.1+
- **Language**: Dart
- **AI Service**: Google Gemini API
- **Local Storage**: SharedPreferences
- **File Handling**: File Picker
- **UI**: Material Design with Google Fonts
- **URL Handling**: URL Launcher

## 📋 Supported Technical Positions

The app includes a comprehensive list of technical positions:

- Software Engineer
- Frontend/Backend/Full Stack Developer
- Mobile App Developer (iOS/Android/Flutter/React Native)
- DevOps Engineer & SRE
- Data Engineer & Data Scientist
- Machine Learning & AI Engineer
- Cloud Engineer (AWS/Azure/GCP)
- Security Engineer & Cybersecurity Analyst
- QA Engineer & Test Automation
- Product Manager & Engineering Manager
- UI/UX Designer & Technical Writer
- And many more...

## 🔧 Configuration

### Environment Variables
- `GEMINI_API_KEY`: Your Google Gemini API key

### API Configuration
- **Base URL**: `https://generativelanguage.googleapis.com/v1beta`
- **Model**: `gemini-1.5-flash`
- **Temperature**: 0.7 (General) / 0.8 (Curated)
- **Max Tokens**: 1024 (General) / 1500 (Curated)

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/your-repo/coldmail/issues) page
2. Create a new issue with detailed information
3. Include your Flutter version and device information

## 🔄 Changelog

### Version 1.0.0
- ✨ Initial release with basic email generation
- 🎯 Added company name and position input
- 🔄 Implemented two template types (General/Curated)
- 💾 Added local template storage
- 📱 Created template management screen
- 🔗 Direct Gmail integration
- 🎨 Enhanced UI with modern design
- 📋 Comprehensive technical position dropdown

---

**Made with ❤️ for job seekers everywhere**
