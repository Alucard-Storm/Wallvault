enum GlassPreset {
  regular,
  clear,
  frosted,
  smoked,
}

extension GlassPresetLabel on GlassPreset {
  String get label => switch (this) {
    GlassPreset.regular => 'Regular',
    GlassPreset.clear => 'Clear',
    GlassPreset.frosted => 'Frosted',
    GlassPreset.smoked => 'Smoked',
  };

  String get description => switch (this) {
    GlassPreset.regular => 'Balanced Apple-style glass',
    GlassPreset.clear => 'Transparent with crisp refraction',
    GlassPreset.frosted => 'Soft blur for readable surfaces',
    GlassPreset.smoked => 'Dark, tinted glass',
  };
}