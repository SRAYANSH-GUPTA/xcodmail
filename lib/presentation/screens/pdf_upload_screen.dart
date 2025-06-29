import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/template_service.dart';
import '../../core/constants.dart';
import 'templates_screen.dart';
import 'dart:developer' as dev;

class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _generatedEmail;
  Map<String, String>? _keyInfo;
  bool _isGeneratingEmail = false;
  
  // New form fields
  final TextEditingController _companyController = TextEditingController();
  String? _selectedPosition;
  String _selectedTemplateType = AppConstants.generalTemplate;
  bool _isCustomPosition = false;
  final TextEditingController _customPositionController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _customPositionController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          dev.log('Selected file: ${_selectedFile?.name}');
          _isLoading = false;
          _generatedEmail = null;
          _keyInfo = null;
        });
        
      
        await _processPdf();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  Future<void> _processPdf() async {
    if (_selectedFile == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Extract text from PDF
      dev.log('Processing PDF: ${_selectedFile?.name}');
      // final String extractedText = await PdfService.extractTextFromPdf(_selectedFile!);
      
        setState(() {
          // _pdfText = extractedText;
          _isLoading = false;
        });

      // Generate cold email using Gemini API
      await _generateColdEmail();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error processing PDF: $e');
    }
  }

  Future<void> _generateColdEmail() async {
    if (_selectedFile == null) return;
    
    // Validate required fields
    if (_companyController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a company name');
      return;
    }
    
    final position = _isCustomPosition 
        ? _customPositionController.text.trim()
        : _selectedPosition;
    
    if (position == null || position.isEmpty) {
      _showErrorSnackBar('Please select or enter a position');
      return;
    }
    
    try {
      setState(() {
        _isGeneratingEmail = true;
      });
      
      // Extract key information first
      // final keyInfo = await GeminiService.extractKeyInfo(_selectedFile!);
      // dev.log('Key info: $keyInfo');
      
      // Generate cold email
      final generatedEmail = await GeminiService.generateColdEmail(
        _selectedFile!,
        companyName: _companyController.text.trim(),
        position: position,
        templateType: _selectedTemplateType,
      );
      
      setState(() {
        // _keyInfo = keyInfo;
        _generatedEmail = generatedEmail;
        _isGeneratingEmail = false;
      });
      
    } catch (e) {
      setState(() {
        _isGeneratingEmail = false;
      });
      dev.log('Error generating email in pdf_upload_screen: $e');
      _showErrorSnackBar('Error generating email: $e');
    }
  }

  Future<void> _saveTemplate() async {
    if (_generatedEmail == null) {
      _showErrorSnackBar('No email to save');
      return;
    }
    
    if (_companyController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a company name');
      return;
    }
    
    final position = _isCustomPosition 
        ? _customPositionController.text.trim()
        : _selectedPosition;
    
    if (position == null || position.isEmpty) {
      _showErrorSnackBar('Please select or enter a position');
      return;
    }
    
    try {
      final template = EmailTemplate(
        id: TemplateService.generateTemplateId(),
        companyName: _companyController.text.trim(),
        position: position,
        emailContent: _generatedEmail!,
        templateType: _selectedTemplateType,
        createdAt: DateTime.now(),
      );
      
      await TemplateService.saveTemplate(template);
      _showInfoSnackBar('Template saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Error saving template: $e');
    }
  }

  void _navigateToTemplates() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TemplatesScreen(),
      ),
    );
  }

  Future<void> _redirectToGmail() async {
    if (_generatedEmail == null) {
      _showErrorSnackBar('Please wait for email generation to complete');
      return;
    }

    try {
      // Try multiple approaches to open Gmail
      bool success = false;
      
      // Approach 1: Try Gmail app with mailto scheme
      final mailtoUrl = Uri.parse('mailto:?subject=Cold%20Outreach%20Email&body=${Uri.encodeComponent(_generatedEmail!)}');
      dev.log('Trying mailto URL: ${mailtoUrl.toString()}');
      
      if (await canLaunchUrl(mailtoUrl)) {
        try {
          await launchUrl(mailtoUrl, mode: LaunchMode.externalApplication);
          success = true;
          dev.log('Successfully opened with mailto');
        } catch (e) {
          dev.log('Failed to open mailto: $e');
        }
      }
      
      // Approach 2: Try Gmail web with shorter content
      if (!success) {
        String truncatedEmail = _generatedEmail!;
        if (truncatedEmail.length > 500) {
          truncatedEmail = truncatedEmail.substring(0, 500) + '...\n\n[Email content truncated. Please copy the full content from the app.]';
        }
        
        String cleanEmail = Uri.encodeComponent(truncatedEmail);
        final gmailWebUrl = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=Cold%20Outreach%20Email&body=$cleanEmail'
        );
        
        dev.log('Trying Gmail web URL length: ${gmailWebUrl.toString().length}');
        
        if (await canLaunchUrl(gmailWebUrl)) {
          try {
            await launchUrl(gmailWebUrl, mode: LaunchMode.externalApplication);
            success = true;
            dev.log('Successfully opened Gmail web');
          } catch (e) {
            dev.log('Failed to open Gmail web: $e');
          }
        }
      }
      
      // Approach 3: Try simple Gmail compose URL
      if (!success) {
        final simpleGmailUrl = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=Cold%20Outreach%20Email');
        dev.log('Trying simple Gmail URL');
        
        if (await canLaunchUrl(simpleGmailUrl)) {
          try {
            await launchUrl(simpleGmailUrl, mode: LaunchMode.externalApplication);
            success = true;
            _showInfoSnackBar('Gmail opened. Please copy the generated email content from above.');
            dev.log('Successfully opened simple Gmail URL');
          } catch (e) {
            dev.log('Failed to open simple Gmail URL: $e');
          }
        }
      }
      
      // Approach 4: Try default browser with Gmail
      if (!success) {
        final browserGmailUrl = Uri.parse('https://mail.google.com');
        dev.log('Trying browser Gmail URL');
        
        if (await canLaunchUrl(browserGmailUrl)) {
          try {
            await launchUrl(browserGmailUrl, mode: LaunchMode.externalApplication);
            success = true;
            _showInfoSnackBar('Gmail opened in browser. Please copy the generated email content from above.');
            dev.log('Successfully opened Gmail in browser');
          } catch (e) {
            dev.log('Failed to open Gmail in browser: $e');
          }
        }
      }
      
      // If all attempts failed, copy content to clipboard and try to open Gmail app
      if (!success) {
        dev.log('All Gmail opening attempts failed, copying to clipboard and trying Gmail app');
        
        // Copy email content to clipboard
        try {
          await Clipboard.setData(ClipboardData(text: _generatedEmail!));
          dev.log('Email content copied to clipboard successfully');
        } catch (e) {
          dev.log('Failed to copy to clipboard: $e');
        }
        
        // Try to open Gmail app directly
        final gmailAppUrl = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=Cold%20Outreach%20Email');
        if (await canLaunchUrl(gmailAppUrl)) {
          try {
            await launchUrl(gmailAppUrl, mode: LaunchMode.externalApplication);
            _showInfoSnackBar('Email content copied to clipboard! Gmail opened. You can paste the content.');
            dev.log('Successfully opened Gmail app after copying to clipboard');
          } catch (e) {
            dev.log('Failed to open Gmail app after copying: $e');
            _showInfoSnackBar('Email content copied to clipboard! Please open Gmail manually and paste the content.');
          }
        } else {
          _showInfoSnackBar('Email content copied to clipboard! Please open Gmail manually and paste the content.');
        }
      }
      
    } catch (e) {
      dev.log('Error in _redirectToGmail: $e');
      _showErrorSnackBar('Error opening Gmail: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A73E8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    if (_generatedEmail == null) {
      _showErrorSnackBar('No email content to copy');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: _generatedEmail!));
      _showInfoSnackBar('Email content copied to clipboard!');
    } catch (e) {
      dev.log('Error copying to clipboard: $e');
      _showErrorSnackBar('Error copying to clipboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'ColdMail',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateToTemplates,
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Saved Templates',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload PDF & Generate Cold Email',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a PDF document and we\'ll help you create personalized cold outreach emails using AI',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Company and Position Form Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Company Name Input
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: 'Company Name *',
                      hintText: 'Enter the company name',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Position Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Position *',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Custom Position Toggle
                      Row(
                        children: [
                          Checkbox(
                            value: _isCustomPosition,
                            onChanged: (value) {
                              setState(() {
                                _isCustomPosition = value ?? false;
                                if (!_isCustomPosition) {
                                  _customPositionController.clear();
                                }
                              });
                            },
                          ),
                          Text(
                            'Custom Position',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      
                      if (_isCustomPosition) ...[
                        TextFormField(
                          controller: _customPositionController,
                          decoration: InputDecoration(
                            labelText: 'Enter Custom Position',
                            hintText: 'e.g., Senior Flutter Developer',
                            prefixIcon: const Icon(Icons.work),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          style: GoogleFonts.poppins(),
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          value: _selectedPosition,
                          decoration: InputDecoration(
                            labelText: 'Select Position',
                            prefixIcon: const Icon(Icons.work),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: AppConstants.technicalPositions.map((position) {
                            return DropdownMenuItem(
                              value: position,
                              child: Text(
                                position,
                                style: GoogleFonts.poppins(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          },
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Template Type Filter Chips
                  Text(
                    'Email Template Type',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTemplateTypeChip(
                          AppConstants.generalTemplate,
                          'Suitable for all companies',
                          Icons.public,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTemplateTypeChip(
                          AppConstants.curatedTemplate,
                          'Specifically curated',
                          Icons.auto_awesome,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // File Upload Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_selectedFile == null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: _isLoading ? null : _pickPdfFile,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else ...[
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to upload PDF',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supports PDF files only',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Selected File Display
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile!.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _generatedEmail = null;
                                _keyInfo = null;
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Upload Button
                  if (_selectedFile == null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickPdfFile,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _isLoading ? 'Uploading...' : 'Choose PDF File',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key Information Section
            if (_keyInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF1A73E8),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Extracted Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._keyInfo!.entries.map((entry) {
                      if (entry.value != 'Not specified' && entry.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatKey(entry.key)}: ',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Generated Email Section
            if (_generatedEmail != null) ...[
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: const Color(0xFF34A853),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Generated Cold Email',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _generatedEmail!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: Text(
                                'Copy Email',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _redirectToGmail,
                              icon: const Icon(Icons.email),
                              label: Text(
                                'Open Gmail',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34A853),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saveTemplate,
                        icon: const Icon(Icons.save),
                        label: Text(
                          'Save Template',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Loading State for Email Generation
            if (_isGeneratingEmail) ...[
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Generating personalized cold email...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a few moments',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),

            // Features Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.security,
                    title: 'Privacy Focused',
                    description: 'Your data stays private and secure',
                  ),
                  _buildFeatureItem(
                    icon: Icons.auto_awesome,
                    title: 'AI Powered',
                    description: 'Uses Gemini API for intelligent email generation',
                  ),
                  _buildFeatureItem(
                    icon: Icons.speed,
                    title: 'Fast Processing',
                    description: 'Quick PDF analysis and email generation',
                  ),
                  _buildFeatureItem(
                    icon: Icons.person,
                    title: 'Personalized',
                    description: 'Creates tailored emails based on PDF content',
                  ),
                  _buildFeatureItem(
                    icon: Icons.save,
                    title: 'Template Storage',
                    description: 'Save and reuse your email templates',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTypeChip(String type, String description, IconData icon) {
    final isSelected = _selectedTemplateType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTemplateType = type;
        });
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A73E8).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1A73E8),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 