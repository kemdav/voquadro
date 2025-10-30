import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';
import 'package:voquadro/src/ai-integration/cloud_ai_service.dart';

/// Debug screen to check Cloud AI configuration and availability
///
/// Use this to troubleshoot why Cloud AI is not working
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => CloudAIDebugScreen()),
/// );
/// ```
class CloudAIDebugScreen extends StatefulWidget {
  const CloudAIDebugScreen({super.key});

  @override
  State<CloudAIDebugScreen> createState() => _CloudAIDebugScreenState();
}

class _CloudAIDebugScreenState extends State<CloudAIDebugScreen> {
  bool _isChecking = false;
  String _status = 'Not checked yet';
  final List<String> _debugInfo = [];

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isChecking = true;
      _debugInfo.clear();
      _status = 'Running diagnostics...';
    });

    try {
      // 1. Check if dotenv is loaded
      _debugInfo.add('=== Environment Check ===');

      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      _debugInfo.add('✓ dotenv loaded: ${dotenv.env.isNotEmpty}');
      _debugInfo.add('API Key found: ${apiKey.isNotEmpty}');

      if (apiKey.isNotEmpty) {
        // Mask the API key for security
        final masked =
            '${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}';
        _debugInfo.add('API Key (masked): $masked');
        _debugInfo.add('API Key length: ${apiKey.length} chars');
      } else {
        _debugInfo.add('⚠️ PROBLEM: API Key is empty!');
        _debugInfo.add(
          '   Check your .env file has: GEMINI_API_KEY=your_key_here',
        );
      }

      _debugInfo.add('');
      _debugInfo.add('=== Cloud AI Service Check ===');

      // 2. Force check Cloud AI availability
      final cloudAI = CloudAIService.instance;
      final isAvailable = await cloudAI.forceCheckAvailability();

      _debugInfo.add('Cloud AI Available: $isAvailable');

      _debugInfo.add('');
      _debugInfo.add('=== Hybrid AI Service Check ===');

      // 3. Check Hybrid AI
      final hybridAI = HybridAIService.instance;
      await hybridAI.forceCheckAIAvailability();

      _debugInfo.add('Active Service: ${hybridAI.activeAIService}');
      _debugInfo.add('Cloud AI: ${hybridAI.isCloudAIAvailable}');
      _debugInfo.add('Ollama: ${hybridAI.isOllamaAvailable}');
      _debugInfo.add('Using Fallback: ${hybridAI.isUsingFallback}');

      _debugInfo.add('');
      _debugInfo.add('=== Environment Variables ===');
      _debugInfo.add(
        'SUPABASE_URL: ${dotenv.env['SUPABASE_URL'] != null ? "✓ Set" : "✗ Missing"}',
      );
      _debugInfo.add(
        'SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY'] != null ? "✓ Set" : "✗ Missing"}',
      );
      _debugInfo.add(
        'OLLAMA_BASE_URL: ${dotenv.env['OLLAMA_BASE_URL'] != null ? "✓ Set" : "✗ Missing"}',
      );
      _debugInfo.add(
        'OLLAMA_MODEL_NAME: ${dotenv.env['OLLAMA_MODEL_NAME'] != null ? "✓ Set" : "✗ Missing"}',
      );
      _debugInfo.add(
        'GEMINI_API_KEY: ${dotenv.env['GEMINI_API_KEY'] != null ? "✓ Set" : "✗ Missing"}',
      );

      if (isAvailable) {
        setState(() {
          _status = '✅ Cloud AI is working!';
        });
      } else if (apiKey.isEmpty) {
        setState(() {
          _status = '⚠️ API Key not found in .env file';
        });
      } else {
        setState(() {
          _status = '❌ Cloud AI check failed - check internet connection';
        });
      }
    } catch (e) {
      _debugInfo.add('');
      _debugInfo.add('=== ERROR ===');
      _debugInfo.add('Error: $e');

      setState(() {
        _status = '❌ Error during diagnostics';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud AI Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _runDiagnostics,
            tooltip: 'Re-run diagnostics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _status.contains('✅')
                  ? Colors.green.shade50
                  : _status.contains('❌')
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _status.contains('✅')
                    ? Colors.green
                    : _status.contains('❌')
                    ? Colors.red
                    : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (_isChecking)
                  const CircularProgressIndicator()
                else
                  Icon(
                    _status.contains('✅')
                        ? Icons.check_circle
                        : _status.contains('❌')
                        ? Icons.error
                        : Icons.warning,
                    color: _status.contains('✅')
                        ? Colors.green
                        : _status.contains('❌')
                        ? Colors.red
                        : Colors.orange,
                    size: 48,
                  ),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Debug Info
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: _debugInfo.length,
                itemBuilder: (context, index) {
                  final line = _debugInfo[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: line.contains('⚠️') || line.contains('✗')
                            ? Colors.orange
                            : line.contains('✓')
                            ? Colors.green
                            : line.contains('===')
                            ? Colors.blue
                            : Colors.black87,
                        fontWeight: line.contains('===')
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _runDiagnostics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-run Diagnostics'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _copyToClipboard();
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Results'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    //final text = _debugInfo.join('\n');
    // You can use Clipboard.setData here if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug info ready to copy:\n${_debugInfo.length} lines'),
      ),
    );
  }
}
