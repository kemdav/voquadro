import 'package:flutter/material.dart';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';

/// Example widget showing how to display AI service status in your app
/// 
/// This widget shows:
/// - Which AI service is currently active (Cloud AI, Ollama, or Fallback)
/// - Visual indicator with appropriate icon and color
/// - Can be placed in app bar, settings, or anywhere you want to show AI status
class AIStatusIndicator extends StatefulWidget {
  const AIStatusIndicator({super.key});

  @override
  State<AIStatusIndicator> createState() => _AIStatusIndicatorState();
}

class _AIStatusIndicatorState extends State<AIStatusIndicator> {
  final HybridAIService _ai = HybridAIService.instance;

  @override
  void initState() {
    super.initState();
    // Check AI availability when widget loads
    _ai.checkAIAvailability();
    // Listen for changes
    _ai.addListener(_onAIStatusChanged);
  }

  @override
  void dispose() {
    _ai.removeListener(_onAIStatusChanged);
    super.dispose();
  }

  void _onAIStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        _getIcon(),
        color: Colors.white,
        size: 16,
      ),
      label: Text(
        _ai.activeAIService,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getColor(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  IconData _getIcon() {
    if (_ai.isCloudAIAvailable) {
      return Icons.cloud;
    } else if (_ai.isOllamaAvailable) {
      return Icons.computer;
    } else {
      return Icons.offline_bolt;
    }
  }

  Color _getColor() {
    if (_ai.isCloudAIAvailable) {
      return Colors.blue; // Cloud AI - primary
    } else if (_ai.isOllamaAvailable) {
      return Colors.green; // Ollama - secondary
    } else {
      return Colors.grey; // Fallback - offline
    }
  }
}

/// Detailed AI status card for settings or debug screen
class AIStatusCard extends StatefulWidget {
  const AIStatusCard({super.key});

  @override
  State<AIStatusCard> createState() => _AIStatusCardState();
}

class _AIStatusCardState extends State<AIStatusCard> {
  final HybridAIService _ai = HybridAIService.instance;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _ai.addListener(_onAIStatusChanged);
  }

  @override
  void dispose() {
    _ai.removeListener(_onAIStatusChanged);
    super.dispose();
  }

  void _onAIStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _recheckAvailability() async {
    setState(() {
      _isChecking = true;
    });

    await _ai.forceCheckAIAvailability();

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Active Service: ${_ai.activeAIService}'),
          backgroundColor: _ai.isCloudAIAvailable
              ? Colors.blue
              : _ai.isOllamaAvailable
                  ? Colors.green
                  : Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Service Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isChecking ? null : _recheckAvailability,
                  tooltip: 'Recheck AI availability',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'Cloud AI (Gemini)',
              _ai.isCloudAIAvailable,
              'Best for mobile devices',
              Icons.cloud,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Ollama',
              _ai.isOllamaAvailable,
              'Local AI for desktop',
              Icons.computer,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Fallback',
              _ai.isUsingFallback,
              'Static content (offline)',
              Icons.offline_bolt,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _ai.isCloudAIAvailable
                    ? Colors.blue.withOpacity(0.1)
                    : _ai.isOllamaAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _ai.isCloudAIAvailable
                        ? Colors.blue
                        : _ai.isOllamaAvailable
                            ? Colors.green
                            : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _ai.activeAIService,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    bool isActive,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isActive ? Icons.check_circle : Icons.circle_outlined,
          color: isActive ? Colors.green : Colors.grey,
          size: 20,
        ),
      ],
    );
  }
}

/// Simple usage example in your app
/// 
/// In your AppBar:
/// ```dart
/// AppBar(
///   title: Text('VoQuadro'),
///   actions: [
///     AIStatusIndicator(),
///     SizedBox(width: 8),
///   ],
/// )
/// ```
/// 
/// In your settings screen:
/// ```dart
/// ListView(
///   children: [
///     AIStatusCard(),
///     // ... other settings
///   ],
/// )
/// ```
