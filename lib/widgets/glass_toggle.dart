import 'package:flutter/material.dart';

/// A beautiful glass-styled toggle switch
class GlassToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const GlassToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: value
                ? [
                    primaryColor.withValues(alpha: 0.35),
                    primaryColor.withValues(alpha: 0.25),
                  ]
                : [
                    (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                    (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value
                ? primaryColor.withValues(alpha: 0.4)
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: value ? primaryColor : Colors.grey.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: value
                        ? primaryColor.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: value ? 8 : 4,
                    spreadRadius: value ? 1 : 0,
                  ),
                ],
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
