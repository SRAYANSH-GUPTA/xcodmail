import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../data/services/template_service.dart';
import '../../core/constants.dart';
import 'dart:developer' as dev;

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<EmailTemplate> _templates = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final templates = await TemplateService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading templates: $e');
    }
  }

  List<EmailTemplate> get _filteredTemplates {
    if (_selectedFilter == 'All') {
      return _templates;
    }
    return _templates.where((template) => template.templateType == _selectedFilter).toList();
  }

  Future<void> _openInGmail(EmailTemplate template) async {
    try {
      // Extract subject and body from the email content
      final lines = template.emailContent.split('\n');
      String subject = 'Cold Outreach Email';
      String body = template.emailContent;
      
      // Try to extract subject if it exists
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().startsWith('subject:')) {
          subject = lines[i].substring('subject:'.length).trim();
          // Remove the subject line from body
          body = lines.skip(i + 1).join('\n').trim();
          break;
        }
      }

      // Try multiple approaches to open Gmail
      bool success = false;
      
      // Approach 1: Try Gmail app with mailto scheme
      final mailtoUrl = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
      
      if (await canLaunchUrl(mailtoUrl)) {
        try {
          await launchUrl(mailtoUrl, mode: LaunchMode.externalApplication);
          success = true;
        } catch (e) {
          dev.log('Failed to open mailto: $e');
        }
      }
      
      // Approach 2: Try Gmail web
      if (!success) {
        String truncatedBody = body;
        if (truncatedBody.length > 500) {
          truncatedBody = truncatedBody.substring(0, 500) + '...\n\n[Email content truncated. Please copy the full content from the app.]';
        }
        
        final gmailWebUrl = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(truncatedBody)}'
        );
        
        if (await canLaunchUrl(gmailWebUrl)) {
          try {
            await launchUrl(gmailWebUrl, mode: LaunchMode.externalApplication);
            success = true;
          } catch (e) {
            dev.log('Failed to open Gmail web: $e');
          }
        }
      }
      
      // Approach 3: Copy to clipboard and open Gmail
      if (!success) {
        await Clipboard.setData(ClipboardData(text: body));
        final gmailUrl = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=${Uri.encodeComponent(subject)}');
        
        if (await canLaunchUrl(gmailUrl)) {
          try {
            await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
            _showInfoSnackBar('Email content copied to clipboard! Gmail opened.');
          } catch (e) {
            _showInfoSnackBar('Email content copied to clipboard! Please open Gmail manually.');
          }
        } else {
          _showInfoSnackBar('Email content copied to clipboard! Please open Gmail manually.');
        }
      }
      
    } catch (e) {
      dev.log('Error opening Gmail: $e');
      _showErrorSnackBar('Error opening Gmail: $e');
    }
  }

  Future<void> _deleteTemplate(EmailTemplate template) async {
    try {
      await TemplateService.deleteTemplate(template.id);
      await _loadTemplates();
      _showInfoSnackBar('Template deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting template: $e');
    }
  }

  void _showDeleteDialog(EmailTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Template',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this template for ${template.companyName}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTemplate(template);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Saved Templates',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_templates.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Clear All Templates',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    content: Text(
                      'Are you sure you want to delete all saved templates?',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            await TemplateService.clearAllTemplates();
                            await _loadTemplates();
                            _showInfoSnackBar('All templates cleared');
                          } catch (e) {
                            _showErrorSnackBar('Error clearing templates: $e');
                          }
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (_templates.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.generalTemplate),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.curatedTemplate),
                  ],
                ),
              ),
            ),
          ],

          // Templates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTemplates.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = _filteredTemplates[index];
                          return _buildTemplateCard(template);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1A73E8),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.email_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Create your first email template to see it here'
                : 'No $_selectedFilter templates found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(EmailTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: template.templateType == AppConstants.curatedTemplate
                  ? const Color(0xFF1A73E8).withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: template.templateType == AppConstants.curatedTemplate
                        ? const Color(0xFF1A73E8)
                        : Colors.grey[600],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    template.templateType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(template.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.position,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF1A73E8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _truncateEmailContent(template.emailContent),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInGmail(template),
                      icon: const Icon(Icons.email, size: 20),
                      label: Text(
                        'Open in Gmail',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34A853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    onPressed: () => _showDeleteDialog(template),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _truncateEmailContent(String content) {
    // Remove subject line if present
    final lines = content.split('\n');
    String body = content;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().startsWith('subject:')) {
        body = lines.skip(i + 1).join('\n').trim();
        break;
      }
    }
    
    if (body.length > 200) {
      return body.substring(0, 200) + '...';
    }
    return body;
  }
} 