/// Utility functions for building and parsing filter strings
library;

/// Build categories string from map
String buildCategoriesString(Map<String, bool> categories) {
  return '${categories['general']! ? '1' : '0'}'
      '${categories['anime']! ? '1' : '0'}'
      '${categories['people']! ? '1' : '0'}';
}

/// Build purity string from map
String buildPurityString(Map<String, bool> purity) {
  return '${purity['sfw']! ? '1' : '0'}'
      '${purity['sketchy']! ? '1' : '0'}'
      '${purity['nsfw']! ? '1' : '0'}';
}

/// Parse categories string to map
Map<String, bool> parseCategoriesString(String categories) {
  return {
    'general': categories[0] == '1',
    'anime': categories[1] == '1',
    'people': categories[2] == '1',
  };
}

/// Parse purity string to map
Map<String, bool> parsePurityString(String purity) {
  return {
    'sfw': purity[0] == '1',
    'sketchy': purity[1] == '1',
    'nsfw': purity.length > 2 && purity[2] == '1',
  };
}

/// Build ratios string from map (comma-separated list of selected ratios)
String buildRatiosString(Map<String, bool> ratios) {
  final selectedRatios = ratios.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  return selectedRatios.isEmpty ? '' : selectedRatios.join(',');
}

/// Parse ratios string to map
Map<String, bool> parseRatiosString(String? ratios) {
  final ratioList = ratios?.split(',') ?? [];

  return {
    '16x9': ratioList.contains('16x9'),
    '16x10': ratioList.contains('16x10'),
    '21x9': ratioList.contains('21x9'),
    '32x9': ratioList.contains('32x9'),
    '9x16': ratioList.contains('9x16'),
    '10x16': ratioList.contains('10x16'),
    '9x21': ratioList.contains('9x21'),
    '1x1': ratioList.contains('1x1'),
    '4x3': ratioList.contains('4x3'),
    '3x2': ratioList.contains('3x2'),
  };
}
