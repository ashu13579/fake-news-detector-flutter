import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import 'result_card.dart';

class AnalysisHistory extends StatelessWidget {
  const AnalysisHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    if (newsProvider.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Analysis History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Analyze your first article to see results here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () {
                // Switch to analyze tab (you'd need to pass a callback for this)
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Analyze Article'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${newsProvider.articles.length} ${newsProvider.articles.length == 1 ? 'Result' : 'Results'}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showClearDialog(context, newsProvider),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Clear All'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: newsProvider.articles.length,
            itemBuilder: (context, index) {
              final article = newsProvider.articles[index];
              return ResultCard(
                article: article,
                onDelete: () => _showDeleteDialog(context, newsProvider, index),
              ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, NewsProvider newsProvider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Delete Analysis'),
        content: const Text(
          'Are you sure you want to delete this analysis result?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              newsProvider.removeArticle(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Analysis deleted'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _showClearDialog(BuildContext context, NewsProvider newsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(
          Icons.warning_amber_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to clear all analysis history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              newsProvider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('History cleared'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
