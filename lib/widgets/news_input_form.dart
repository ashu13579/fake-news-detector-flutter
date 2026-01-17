import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/news_provider.dart';

class NewsInputForm extends StatefulWidget {
  const NewsInputForm({super.key});

  @override
  State<NewsInputForm> createState() => _NewsInputFormState();
}

class _NewsInputFormState extends State<NewsInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrlController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fact_check_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analyze News Article',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste article content or add an image to verify authenticity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).scale(delay: 100.ms),
            
            const SizedBox(height: 24),

            // Title Input
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Article Title',
                hintText: 'Enter the news headline',
                prefixIcon: const Icon(Icons.title_rounded),
                helperText: 'The main headline of the article',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 20),

            // Content Input
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Article Content',
                hintText: 'Paste the full article text here...',
                prefixIcon: const Icon(Icons.article_rounded),
                helperText: 'Minimum 50 characters required',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter article content';
                }
                if (value.length < 50) {
                  return 'Content too short for analysis (min 50 chars)';
                }
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 20),

            // Source URL Input
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Source URL (Optional)',
                hintText: 'https://example.com/article',
                prefixIcon: Icon(Icons.link_rounded),
                helperText: 'Link to the original article',
              ),
              keyboardType: TextInputType.url,
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 24),

            // Image Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.image_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Image (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Change Image'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Remove'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Image'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'OR',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'https://example.com/image.jpg',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
            
            const SizedBox(height: 32),

            // Analyze Button
            FilledButton.icon(
              onPressed: newsProvider.isLoading
                  ? null
                  : () => _analyzeNews(newsProvider),
              icon: newsProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.psychology_rounded),
              label: Text(
                newsProvider.isLoading ? 'Analyzing with AI...' : 'Analyze Article',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).shimmer(delay: 600.ms, duration: 1500.ms),

            if (newsProvider.error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        newsProvider.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeNews(NewsProvider newsProvider) async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text;
      
      // If local image is selected, you would need to upload it to a server
      // For now, we'll just use the URL if provided
      if (_selectedImage != null) {
        // In a real app, upload the image and get the URL
        // imageUrl = await uploadImage(_selectedImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note: Local image upload requires a server. Using URL analysis only.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await newsProvider.analyzeNews(
        _titleController.text,
        _contentController.text,
        url: _urlController.text.isEmpty ? null : _urlController.text,
        imageUrl: imageUrl,
      );

      if (mounted && newsProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Analysis complete! Check the History tab.'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Clear form
        _titleController.clear();
        _contentController.clear();
        _urlController.clear();
        _imageUrlController.clear();
        setState(() {
          _selectedImage = null;
        });
      }
    }
  }
}
