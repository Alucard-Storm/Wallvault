import 'package:flutter/material.dart';

/// Configuration for gesture detection and handling
class GestureConfig {
  /// Swipe gesture thresholds
  static const double swipeMinDistance = 100.0;
  static const double swipeMinVelocity = 300.0;
  static const double swipeMaxOffPathDistance = 50.0;
  
  /// Long press duration
  static const Duration longPressDuration = Duration(milliseconds: 500);
  
  /// Double tap timing
  static const Duration doubleTapTimeout = Duration(milliseconds: 300);
  
  /// Pan gesture thresholds
  static const double panMinDistance = 10.0;
  
  /// Scale gesture thresholds
  static const double scaleMinScale = 0.8;
  static const double scaleMaxScale = 3.0;
  
  /// Determine swipe direction
  static SwipeDirection? detectSwipeDirection(
    DragEndDetails details,
    Offset startPosition,
    Offset endPosition,
  ) {
    final dx = endPosition.dx - startPosition.dx;
    final dy = endPosition.dy - startPosition.dy;
    final distance = (endPosition - startPosition).distance;
    final velocity = details.velocity.pixelsPerSecond.distance;
    
    // Check if swipe meets minimum requirements
    if (distance < swipeMinDistance || velocity < swipeMinVelocity) {
      return null;
    }
    
    // Determine primary direction
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx.abs() > swipeMaxOffPathDistance) {
        return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      }
    } else {
      // Vertical swipe
      if (dy.abs() > swipeMaxOffPathDistance) {
        return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      }
    }
    
    return null;
  }
  
  /// Check if gesture is a tap (not a drag)
  static bool isTap(Offset startPosition, Offset endPosition) {
    final distance = (endPosition - startPosition).distance;
    return distance < panMinDistance;
  }
}

/// Swipe direction enum
enum SwipeDirection {
  left,
  right,
  up,
  down,
}
