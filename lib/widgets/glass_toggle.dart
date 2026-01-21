import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 32,
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            thickness: value ? 10 : 8,
            blur: 6,
            glassColor: value
                ? primaryColor.withOpacity(0.2)
                : Theme.of(context).brightness == Brightness.dark
                ? const Color(0x0AFFFFFF)
                : const Color(0x0A000000),
          ),
          child: LiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: value
                    ? primaryColor.withOpacity(0.3)
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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
                              ? primaryColor.withOpacity(0.4)
                              : Colors.black.withOpacity(0.2),
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
          ),
        ),
      ),
    );
  }
}
