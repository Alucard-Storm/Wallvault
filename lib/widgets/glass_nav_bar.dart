import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/glass_config.dart';

/// A floating glass navigation bar with iOS 18-style design
class FloatingGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  
  const FloatingGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 20,
          blur: 12,
          glassColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x66000000)
              : const Color(0x66FFFFFF),
        ),
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: 28),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                destinations.length,
                (index) => _buildNavItem(
                  context,
                  destinations[index],
                  index,
                  selectedIndex == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context,
    NavigationDestination destination,
    int index,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6);
    
    return Expanded(
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: color,
                  size: 24,
                ),
                child: isSelected 
                    ? (destination.selectedIcon ?? destination.icon) 
                    : destination.icon,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A glass app bar with frosted glass effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 15,
          blur: 10,
          glassColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x44000000)
              : const Color(0x44FFFFFF),
        ),
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: 0),
          child: AppBar(
            title: Text(title),
            actions: actions,
            leading: leading,
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
