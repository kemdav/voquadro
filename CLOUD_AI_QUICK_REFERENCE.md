# 🎯 Quick Reference: Cloud AI Integration

## 🚀 Quick Start (30 seconds)

```bash
# 1. Get API key from: https://makersuite.google.com/app/apikey

# 2. Add to .env
echo "GEMINI_API_KEY=your_key_here" >> .env

# 3. Run app
flutter run
```

## 📱 Usage in Code

```dart
// Import
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';

// Get instance
final ai = HybridAIService.instance;

// Check availability
await ai.checkAIAvailability();
print(ai.activeAIService); // "Cloud AI (Gemini)" | "Ollama" | "Fallback"

// Generate question
final session = await ai.generateQuestion("Technology");

// Get feedback with scores
final result = await ai.getPublicSpeakingFeedbackWithScores(
  transcript,
  session,
  wordCount: 150,
  fillerCount: 3,
  durationSeconds: 90,
);

// Access results
print(result['feedback']); // Formatted feedback text
print(result['scores']['overall']); // 0-100 score
```

## 🔧 Configuration

### Environment Variables (.env)

```env
# Cloud AI (Primary - Mobile & Web)
GEMINI_API_KEY=your_gemini_api_key_here

# Ollama (Secondary - Desktop Dev)
OLLAMA_BASE_URL=http://10.0.2.2:11434
OLLAMA_MODEL_NAME=qwen2.5:0.5b
```

## 🎨 AI Service States

| State           | isCloudAIAvailable | isOllamaAvailable | activeAIService     |
| --------------- | ------------------ | ----------------- | ------------------- |
| Online Mobile   | ✅ true            | ❌ false          | "Cloud AI (Gemini)" |
| Offline Mobile  | ❌ false           | ❌ false          | "Fallback"          |
| Desktop Dev     | ✅ true            | ✅ true           | "Cloud AI (Gemini)" |
| Desktop Offline | ❌ false           | ✅ true           | "Ollama"            |
| No AI           | ❌ false           | ❌ false          | "Fallback"          |

## 🔄 Priority Cascade

```
User Request
    ↓
Cloud AI? → YES → Use Gemini API → Success? → Return Result
    ↓ NO                              ↓ NO
Ollama? → YES → Use Local AI → Success? → Return Result
    ↓ NO                         ↓ NO
Fallback → Use Static/Rules → Return Result
```

## 🎯 Available Methods

### Availability Checks

```dart
await ai.checkAIAvailability()           // Check all services
await ai.forceCheckAIAvailability()      // Force fresh check
bool isCloud = ai.isCloudAIAvailable     // Check Cloud AI
bool isOllama = ai.isOllamaAvailable     // Check Ollama
bool isFallback = ai.isUsingFallback     // Check if using fallback
String active = ai.activeAIService       // Get active service name
```

### Question Generation

```dart
SpeechSession session = await ai.generateQuestion(String topic)
```

### Feedback & Scores

```dart
// Comprehensive (recommended)
Map<String, dynamic> result = await ai.getPublicSpeakingFeedbackWithScores(
  String transcript,
  SpeechSession session,
  {int wordCount, int fillerCount, int durationSeconds}
)

// Text only
String feedback = await ai.getPublicSpeakingFeedback(
  String transcript,
  SpeechSession session
)

// Individual scores
double content = await ai.contentQualityScore(String transcript)
double clarity = await ai.clarityStructureScore(String transcript)
double overall = await ai.overallScore(String transcript)
```

## 📊 Response Formats

### SpeechSession

```dart
class SpeechSession {
  final String topic;               // e.g., "Technology"
  final String generatedQuestion;   // AI-generated question
  final DateTime timestamp;         // When created
  String? userResponse;             // User's speech
  String? feedback;                 // AI feedback
}
```

### Feedback with Scores

```dart
{
  'feedback': "Content Quality: ...\n\nClarity & Structure: ...",
  'scores': {
    'overall': 85,           // 0-100
    'content_quality': 80,   // 0-100
    'clarity_structure': 90  // 0-100
  },
  'topic': "Technology",
  'question': "How has AI changed..."
}
```

## 🛡️ Error Handling

```dart
try {
  final session = await ai.generateQuestion(topic);
} catch (e) {
  // Automatically falls back to static questions
  // No need to handle - graceful degradation built-in
  print('Using fallback: $e');
}
```

## 💰 Gemini Free Tier Limits

- **Requests**: 15/minute
- **Tokens**: 1M/day
- **Sufficient for**: ~1000+ speeches/day
- **Cost**: FREE

## 🎨 UI Integration Example

```dart
Widget buildAIStatus() {
  return StreamBuilder(
    stream: Stream.periodic(Duration(seconds: 1)),
    builder: (context, snapshot) {
      final ai = HybridAIService.instance;

      return Chip(
        avatar: Icon(
          ai.isCloudAIAvailable ? Icons.cloud :
          ai.isOllamaAvailable ? Icons.computer :
          Icons.offline_bolt,
          color: Colors.white,
        ),
        label: Text(ai.activeAIService),
        backgroundColor: ai.isCloudAIAvailable ? Colors.blue :
                         ai.isOllamaAvailable ? Colors.green :
                         Colors.grey,
      );
    },
  );
}
```

## 🚨 Debug Commands

```dart
// Force check all services
await ai.forceCheckAIAvailability();

// Print status
debugPrint('Cloud AI: ${ai.isCloudAIAvailable}');
debugPrint('Ollama: ${ai.isOllamaAvailable}');
debugPrint('Active: ${ai.activeAIService}');
debugPrint('Fallback: ${ai.isUsingFallback}');

// Get session info
final session = ai.currentSession;
debugPrint('Topic: ${session?.topic}');
debugPrint('Question: ${session?.generatedQuestion}');
```

## 📚 Related Files

```
lib/src/ai-integration/
├── cloud_ai_service.dart          # Cloud AI (Gemini)
├── ollama_service.dart            # Local AI (Ollama)
├── hybrid_ai_service.dart         # Orchestrator ⭐
├── fallback_question_service.dart # Static questions
├── fallback_feedback_service.dart # Rule-based feedback
└── README.md                      # Full documentation
```

## 🔗 Resources

- 🔑 [Get API Key](https://makersuite.google.com/app/apikey)
- 📖 [Setup Guide](./CLOUD_AI_SETUP.md)
- 🌐 [Gemini Docs](https://ai.google.dev/docs)
- 📊 [Usage Dashboard](https://console.cloud.google.com/apis/dashboard)

## ⚡ Performance Tips

```dart
// ✅ Preload on app start
void initState() {
  super.initState();
  HybridAIService.instance.checkAIAvailability();
}

// ✅ Use timeouts
final session = await ai
  .generateQuestion(topic)
  .timeout(Duration(seconds: 30));

// ✅ Show loading states
if (isLoading) return CircularProgressIndicator();

// ✅ Cache results when possible
final _cachedSession = ai.currentSession;
```

---

**TL;DR**: Get API key → Add to `.env` → Run app → It just works! 🎉
