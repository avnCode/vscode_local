import 'package:flutter/material.dart';

class AppTheme {
  // VS Code color palette
  static const Color _bg = Color(0xFF1E1E1E);
  static const Color _sidebar = Color(0xFF252526);
  static const Color _tabBar = Color(0xFF2D2D2D);
  static const Color _accent = Color(0xFF007ACC);
  static const Color _surface = Color(0xFF1E1E1E);
  static const Color _onSurface = Color(0xFFD4D4D4);
  static const Color _onSurfaceMuted = Color(0xFF808080);
  static const Color _divider = Color(0xFF3C3C3C);
  static const Color _hover = Color(0xFF2A2D2E);
  static const Color _activeTab = Color(0xFF1E1E1E);
  static const Color _inactiveTab = Color(0xFF2D2D2D);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      primaryColor: _accent,
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        surface: _surface,
        onSurface: _onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _sidebar,
        foregroundColor: _onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _sidebar,
      ),
      dividerColor: _divider,
      listTileTheme: const ListTileThemeData(
        textColor: _onSurface,
        iconColor: _onSurfaceMuted,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      iconTheme: const IconThemeData(color: _onSurfaceMuted, size: 16),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _onSurface, fontFamily: 'monospace', fontSize: 13),
        bodySmall: TextStyle(color: _onSurfaceMuted, fontSize: 11),
        labelMedium: TextStyle(color: _onSurface, fontSize: 12),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFF424242)),
      ),
      extensions: const [VSCodeColors(
        bg: _bg,
        sidebar: _sidebar,
        tabBar: _tabBar,
        accent: _accent,
        onSurface: _onSurface,
        muted: _onSurfaceMuted,
        divider: _divider,
        hover: _hover,
        activeTab: _activeTab,
        inactiveTab: _inactiveTab,
      )],
    );
  }
}

@immutable
class VSCodeColors extends ThemeExtension<VSCodeColors> {
  final Color bg;
  final Color sidebar;
  final Color tabBar;
  final Color accent;
  final Color onSurface;
  final Color muted;
  final Color divider;
  final Color hover;
  final Color activeTab;
  final Color inactiveTab;

  const VSCodeColors({
    required this.bg,
    required this.sidebar,
    required this.tabBar,
    required this.accent,
    required this.onSurface,
    required this.muted,
    required this.divider,
    required this.hover,
    required this.activeTab,
    required this.inactiveTab,
  });

  @override
  VSCodeColors copyWith({
    Color? bg, Color? sidebar, Color? tabBar, Color? accent,
    Color? onSurface, Color? muted, Color? divider, Color? hover,
    Color? activeTab, Color? inactiveTab,
  }) {
    return VSCodeColors(
      bg: bg ?? this.bg,
      sidebar: sidebar ?? this.sidebar,
      tabBar: tabBar ?? this.tabBar,
      accent: accent ?? this.accent,
      onSurface: onSurface ?? this.onSurface,
      muted: muted ?? this.muted,
      divider: divider ?? this.divider,
      hover: hover ?? this.hover,
      activeTab: activeTab ?? this.activeTab,
      inactiveTab: inactiveTab ?? this.inactiveTab,
    );
  }

  @override
  VSCodeColors lerp(VSCodeColors? other, double t) {
    if (other is! VSCodeColors) return this;
    return VSCodeColors(
      bg: Color.lerp(bg, other.bg, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      tabBar: Color.lerp(tabBar, other.tabBar, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      activeTab: Color.lerp(activeTab, other.activeTab, t)!,
      inactiveTab: Color.lerp(inactiveTab, other.inactiveTab, t)!,
    );
  }
}
