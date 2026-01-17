import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/news_analysis.dart';

class AnalysisResultCard extends StatefulWidget {
  final NewsAnalysis analysis;
  final VoidCallback onClose;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
    required this.onClose,
  });

  @override
  State<AnalysisResultCard> createState() => _AnalysisResultCardState();
}

class _AnalysisResultCardState extends State<AnalysisResultCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getVerdict(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _getIconColor(),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Confidence: ${(widget.analysis.confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _getIconColor().withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${(widget.analysis.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getIconColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: widget.onClose,
                  color: _getIconColor(),
                ),
              ],
            ),
          ),

          // Confidence bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.analysis.confidence,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Analysis text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.analysis.analysis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
            ),
          ),

          const SizedBox(height: 16),

          // Red flags section
          if (widget.analysis.redFlags.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Red Flags Detected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...widget.analysis.redFlags.map((flag) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          flag,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // View detailed analysis button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              icon: Icon(
                _showDetails ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
              label: Text(
                _showDetails ? 'Hide detailed analysis' : 'View detailed analysis',
                style: const TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Detailed analysis (expandable)
          if (_showDetails) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Title', widget.analysis.title),
                  const SizedBox(height: 12),
                  _buildDetailRow('Analyzed', _formatDate(widget.analysis.timestamp)),
                  if (widget.analysis.url != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('Source URL', widget.analysis.url!),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    if (widget.analysis.isFake) {
      return const Color(0xFF8B2635); // Dark red
    } else if (widget.analysis.confidence < 0.7) {
      return const Color(0xFF8B6F2B); // Dark orange/yellow
    } else {
      return const Color(0xFF2B5F3F); // Dark green
    }
  }

  Color _getBorderColor() {
    if (widget.analysis.isFake) {
      return Colors.red.shade400;
    } else if (widget.analysis.confidence < 0.7) {
      return Colors.orange.shade400;
    } else {
      return Colors.green.shade400;
    }
  }

  Color _getIconColor() {
    if (widget.analysis.isFake) {
      return Colors.red.shade300;
    } else if (widget.analysis.confidence < 0.7) {
      return Colors.orange.shade300;
    } else {
      return Colors.green.shade300;
    }
  }

  IconData _getIcon() {
    if (widget.analysis.isFake) {
      return Icons.cancel_rounded;
    } else if (widget.analysis.confidence < 0.7) {
      return Icons.warning_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  String _getVerdict() {
    if (widget.analysis.isFake) {
      return 'Fake News';
    } else if (widget.analysis.confidence < 0.7) {
      return 'Uncertain';
    } else {
      return 'Likely Real';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
