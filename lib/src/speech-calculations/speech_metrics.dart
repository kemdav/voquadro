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
  final words = transcript.toLowerCase().split(RegExp(r'\s+'));
  int count = 0;

  for (var word in words) {
    // Remove punctuation from the word
    word = word.replaceAll(RegExp(r'[^\w\s]'), '');
    if (fillerWords.contains(word)) {
      count++;
    }
  }

  return count;
}

double calculateWordsPerMinute(String transcript, Duration duration) {
  final words = transcript
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;
  final minutes = duration.inSeconds / 60.0;
  if (minutes == 0) return 0.0; // Avoid division by zero
  return words / minutes;
}
