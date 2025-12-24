import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Advanced haptic feedback manager with different patterns for various actions
class HapticManager {
  // Check if device supports vibration
  static Future<bool> get hasVibrator async {
    return await Vibration.hasVibrator() ?? false;
  }
  
  // Check if device supports custom vibrations
  static Future<bool> get hasCustomVibrations async {
    return await Vibration.hasCustomVibrationsSupport() ?? false;
  }
  
  /// Light tap - for button presses
  static Future<void> lightTap() async {
    if (await hasVibrator) {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Medium tap - for selections
  static Future<void> mediumTap() async {
    if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Heavy tap - for important actions
  static Future<void> heavyTap() async {
    if (await hasVibrator) {
      HapticFeedback.heavyImpact();
    }
  }
  
  /// Selection changed - for scrolling through options
  static Future<void> selectionClick() async {
    if (await hasVibrator) {
      HapticFeedback.selectionClick();
    }
  }
  
  /// Success pattern - double short pulse
  static Future<void> success() async {
    if (await hasCustomVibrations) {
      await Vibration.vibrate(
        pattern: [0, 50, 50, 50],
        intensities: [0, 128, 0, 128],
      );
    } else if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Error pattern - long pulse
  static Future<void> error() async {
    if (await hasCustomVibrations) {
      await Vibration.vibrate(
        pattern: [0, 200],
        intensities: [0, 255],
      );
    } else if (await hasVibrator) {
      HapticFeedback.heavyImpact();
    }
  }
  
  /// Favorite pattern - heartbeat (two quick pulses)
  static Future<void> favorite() async {
    if (await hasCustomVibrations) {
      await Vibration.vibrate(
        pattern: [0, 30, 30, 50],
        intensities: [0, 180, 0, 200],
      );
    } else if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Download started - single medium pulse
  static Future<void> downloadStart() async {
    if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Download complete - success pattern
  static Future<void> downloadComplete() async {
    await success();
  }
  
  /// Long press detected - heavy impact
  static Future<void> longPress() async {
    if (await hasVibrator) {
      HapticFeedback.heavyImpact();
    }
  }
  
  /// Swipe gesture - light impact
  static Future<void> swipe() async {
    if (await hasVibrator) {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Menu open - medium impact
  static Future<void> menuOpen() async {
    if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Notification - custom pattern
  static Future<void> notification() async {
    if (await hasCustomVibrations) {
      await Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, 150, 0, 150],
      );
    } else if (await hasVibrator) {
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Cancel vibration
  static Future<void> cancel() async {
    await Vibration.cancel();
  }
}
