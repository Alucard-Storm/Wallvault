import 'package:flutter/material.dart';

class ResponsiveUtils {
  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return 2; // Mobile
    } else if (width < 900) {
      return 3; // Tablet / Small Window
    } else if (width < 1200) {
      return 4; // Desktop
    } else if (width < 1600) {
      return 5; // Large Desktop
    } else {
      return 6; // Ultra Wide
    }
  }
}
