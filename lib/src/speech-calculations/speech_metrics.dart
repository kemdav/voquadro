const List<String> _defaultFillers = [
  'um',
  'uh',
  'like',
  'you know',
  'so',
  'actually',
  'basically',
  'right',
  'i mean',
  'okay',
  'well',
  'hmm',
  'Mhm',
  'huh',
  'mhm',
  'er',
  'ah',
  'oh',
  'eh',
  'Mm',
  'mm',
  'M',
  'm',
];

int countFillerWords(String transcript, {List<String>? fillers}) {
  final fillerWords = fillers ?? _defaultFillers;
  // Lowercase and remove punctuation from transcript
  final cleanedTranscript = transcript.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ');
  int count = 0;

  for (var filler in fillerWords) {
    // Lowercase and remove punctuation from filler phrase
    final cleanedFiller = filler.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
    if (cleanedFiller.isEmpty) continue;
    // Use word boundaries for single-word fillers, and simple substring for multi-word
    final pattern = cleanedFiller.contains(' ')
        ? RegExp(r'\b' + RegExp.escape(cleanedFiller) + r'\b')
        : RegExp(r'\b' + RegExp.escape(cleanedFiller) + r'\b');
    count += pattern.allMatches(cleanedTranscript).length;
  }

  return count;
}

double calculateWordsPerMinute(String transcript, Duration duration) {
  final words = transcript
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;
  final minutes = duration.inMilliseconds / 60000.0;
  if (minutes <= 0) return 0.0; // Avoid division by zero or negative
  return words / minutes;
}
