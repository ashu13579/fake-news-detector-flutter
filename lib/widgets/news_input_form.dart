import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/news_provider.dart';

class NewsInputForm extends StatefulWidget {
  const NewsInputForm({super.key});

  @override
  State<NewsInputForm> createState() => _NewsInputFormState();
}

class _NewsInputFormState extends State<NewsInputForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _imageBase64;
  
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    _tabController.dispose();
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
      // Convert image to base64
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      setState(() {
        _selectedImage = image;
        _imageBase64 = base64Image;
        _imageUrlController.clear();
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Column(
      children: [
        // Hero Section
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ).animate().scale(delay: 100.ms, duration: 600.ms),
              const SizedBox(height: 12),
              Text(
                'TruthLens',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'AI-powered fake news detection. Verify articles, images, and links instantly with advanced machine learning analysis.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFeatureChip('Real-time', Icons.speed),
                  _buildFeatureChip('Multi-format', Icons.dashboard),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),

        // Tab Selector
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            tabs: const [
              Tab(
                icon: Icon(Icons.text_fields, size: 20),
                text: 'Text',
              ),
              Tab(
                icon: Icon(Icons.link, size: 20),
                text: 'URL / Link',
              ),
              Tab(
                icon: Icon(Icons.image, size: 20),
                text: 'Image',
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 20),

        // Form Content - Fixed with proper constraints
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Use IndexedStack instead of TabBarView to avoid height issues
                IndexedStack(
                  index: _currentTab,
                  children: [
                    Column(children: _buildTextTab()),
                    Column(children: _buildUrlTab()),
                    Column(children: _buildImageTab()),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: newsProvider.isLoading
                      ? null
                      : () => _analyzeNews(newsProvider),
                  icon: newsProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    newsProvider.isLoading
                        ? 'Analyzing ${_getTabName()}...'
                        : 'Analyze ${_getTabName()}',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (newsProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
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
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTextTab() {
    return [
      Text(
        'Enter the article details you want to verify...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Article Title',
          hintText: 'Enter the headline',
          prefixIcon: Icon(Icons.title_rounded),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _contentController,
        decoration: const InputDecoration(
          labelText: 'Article Content',
          hintText: 'Paste the article text here',
          prefixIcon: Icon(Icons.article_rounded),
          alignLabelWithHint: true,
        ),
        maxLines: 8,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the article content';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildUrlTab() {
    return [
      Text(
        'Enter the URL of the article you want to verify...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _urlController,
        decoration: const InputDecoration(
          labelText: 'Article URL',
          hintText: 'https://example.com/article',
          prefixIcon: Icon(Icons.link_rounded),
        ),
        keyboardType: TextInputType.url,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a URL';
          }
          if (!value.startsWith('http://') && !value.startsWith('https://')) {
            return 'Please enter a valid URL';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Article Title (Optional)',
          hintText: 'Enter title if known',
          prefixIcon: Icon(Icons.title_rounded),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _contentController,
        decoration: const InputDecoration(
          labelText: 'Article Content (Optional)',
          hintText: 'Paste article text if available',
          prefixIcon: Icon(Icons.article_rounded),
          alignLabelWithHint: true,
        ),
        maxLines: 6,
      ),
    ];
  }

  List<Widget> _buildImageTab() {
    return [
      Text(
        'Upload an image or provide an image URL...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      const SizedBox(height: 16),
      if (_selectedImage != null)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_selectedImage!.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: _removeImage,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        )
      else
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Upload Image from Gallery'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'OR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _imageUrlController,
        decoration: const InputDecoration(
          labelText: 'Image URL',
          hintText: 'https://example.com/image.jpg',
          prefixIcon: Icon(Icons.link),
        ),
        keyboardType: TextInputType.url,
        enabled: _selectedImage == null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Context/Title (Optional)',
          hintText: 'Provide context about the image',
          prefixIcon: Icon(Icons.title_rounded),
        ),
        maxLines: 2,
      ),
    ];
  }

  String _getTabName() {
    switch (_currentTab) {
      case 0:
        return 'Text';
      case 1:
        return 'URL';
      case 2:
        return 'Image';
      default:
        return 'Content';
    }
  }

  Future<void> _analyzeNews(NewsProvider newsProvider) async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text;
      
      // Use base64 image if local image is selected
      if (_selectedImage != null && _imageBase64 != null) {
        // For now, we'll use the image URL field to pass base64
        // In a real implementation, you'd modify the API to accept base64
        imageUrl = 'data:image/jpeg;base64,$_imageBase64';
      }

      // For URL tab, use URL as title if title is empty
      String title = _titleController.text;
      String content = _contentController.text;
      
      if (_currentTab == 1 && title.isEmpty) {
        title = _urlController.text;
      }
      
      if (_currentTab == 1 && content.isEmpty) {
        content = 'Article from: ${_urlController.text}';
      }
      
      // For image tab, provide context
      if (_currentTab == 2) {
        if (title.isEmpty) {
          title = 'Image Analysis';
        }
        if (content.isEmpty) {
          content = 'Analyzing image for fake news indicators and manipulations.';
        }
      }

      await newsProvider.analyzeNews(
        title,
        content,
        url: _urlController.text.isEmpty ? null : _urlController.text,
        imageUrl: imageUrl,
      );

      if (mounted && newsProvider.error == null) {
        // Don't clear form - keep it visible above results
        // Scroll to show results
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Analysis complete! See results below.')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
