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
