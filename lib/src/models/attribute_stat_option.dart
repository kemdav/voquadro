class AttributeStatOption {
  final String
  id; // Unique ID to prevent duplicates (e.g., 'pace', 'filler_words')
  final String name; // Display name (e.g., "Avg Pace")
  final String value; // Display value (e.g., "120 wpm")
  final String assetPath; // Icon path

  AttributeStatOption({
    required this.id,
    required this.name,
    required this.value,
    required this.assetPath,
  });
}
