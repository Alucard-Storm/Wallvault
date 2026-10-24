import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/glass_config.dart';
import 'glass/loupe_tab_bar.dart';

/// A single destination in [FloatingGlassNavBar].
@immutable
class NavBarTab {
  const NavBarTab({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// A floating glass navigation bar with Apple's iOS 27 loupe tab bar effect:
/// a glass capsule whose selection platter turns into a magnifying loupe
/// that follows the finger while held, and springs to the nearest tab on
/// release.
class FloatingGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavBarTab> destinations;

  const FloatingGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static const _shadows = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LiquidGlassLayer(
        settings: GlassConfig.settingsForPreset(context),
        child: LiquidGlassBlendGroup(
          blend: 5,
          child: LoupeTabBar(
            tabs: [
              for (final tab in destinations)
                BottomBarTab(icon: tab.icon, label: tab.label),
            ],
            selectedIndex: selectedIndex,
            onSelected: onDestinationSelected,
            shadows: _shadows,
            appearance: GlassConfig.appearanceForPreset(context),
          ),
        ),
      ),
    );
  }
}

/// A glass app bar with frosted glass effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? appName;
  final String screenName;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    this.appName = 'WallVault',
    required this.screenName,
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
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: LiquidGlassLayer(
        settings: GlassConfig.settingsForPreset(context),
        child: LiquidGlass(
          appearance: GlassConfig.appearanceForPreset(context),
          shape: const LiquidRoundedSuperellipse(borderRadius: 1),
          child: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (appName != null)
                  Text(
                    appName!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                Text(
                  screenName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
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
