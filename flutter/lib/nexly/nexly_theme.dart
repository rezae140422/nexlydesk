// NexlyDesk central theme (dark + light). Source of truth for brand colours.
// Palette: /workspace/nexly/design/palette/nexly-palette.css
// Glow (text-shadow) is allowed ONLY on the slogan text — never on frames.
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
export 'nexly_full_value.dart';

import '../consts.dart';
import '../models/platform_model.dart';

class NexlyColors {
  static const maroon = Color(0xFF6F1D31);
  static const maroonDark = Color(0xFF4A1422);
  static const gold = Color(0xFFB9945A);
  static const cream = Color(0xFFFEF5EC);
  static const ink = Color(0xFF1A0F12);
  static const green = Color(0xFF2F6B4F);
  static const greenLight = Color(0xFF5FA383);

  // dark surfaces
  static const darkBg = maroonDark;
  static const darkCard = Color(0xFF5A1828); // ~ maroon @45% over dark bg
  static const darkCard2 = Color(0xFF3A1019);
  static const darkBorder = Color(0x2EB9945A); // gold @18%
  static const darkMuted = Color(0xFFC4B8AE);
  // light surfaces
  static const lightCard2 = Color(0xFFFBF1E6);
  static const lightBorder = Color(0xFFE8DCD0);
  static const lightMuted = Color(0xFF6E625A);
}

class NexlyTheme {
  static const fontFamily = 'Vazirmatn';

  static bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  static Color primary(BuildContext c) => isDark(c) ? NexlyColors.gold : NexlyColors.maroon;
  static Color onPrimary(BuildContext c) => isDark(c) ? NexlyColors.ink : NexlyColors.cream;
  static Color card(BuildContext c) => isDark(c) ? NexlyColors.darkCard : Colors.white;
  static Color card2(BuildContext c) => isDark(c) ? NexlyColors.darkCard2 : NexlyColors.lightCard2;
  static Color border(BuildContext c) => isDark(c) ? NexlyColors.darkBorder : NexlyColors.lightBorder;
  static Color muted(BuildContext c) => isDark(c) ? NexlyColors.darkMuted : NexlyColors.lightMuted;

  /// Rounded brand card (radius 20, thin border, soft shadow, no glow).
  static BoxDecoration cardDecoration(BuildContext c, {bool alt = false}) => BoxDecoration(
        color: alt ? card2(c) : card(c),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border(c)),
        boxShadow: [
          BoxShadow(
              color: isDark(c) ? const Color(0x59000000) : const Color(0x124A1422),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      );

  /// Slogan style — the only place glow is permitted.
  static TextStyle slogan(BuildContext c) => isDark(c)
      ? const TextStyle(color: NexlyColors.gold, fontSize: 12, shadows: [
          Shadow(color: Color(0x8CB9945A), blurRadius: 10),
          Shadow(color: Color(0x4DB9945A), blurRadius: 22),
        ])
      : const TextStyle(color: NexlyColors.maroon, fontSize: 12);

  static ThemeData apply(ThemeData base, {required bool dark}) {
    final pri = dark ? NexlyColors.gold : NexlyColors.maroon;
    final onPri = dark ? NexlyColors.ink : NexlyColors.cream;
    final bg = dark ? NexlyColors.darkBg : NexlyColors.cream;
    final fg = dark ? NexlyColors.cream : NexlyColors.ink;
    final cardC = dark ? NexlyColors.darkCard : Colors.white;
    final bd = dark ? NexlyColors.darkBorder : NexlyColors.lightBorder;
    return base.copyWith(
      primaryColor: pri,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      cardColor: cardC,
      dividerColor: bd,
      hoverColor: pri.withOpacity(0.08),
      highlightColor: pri.withOpacity(0.10),
      dialogBackgroundColor: cardC,
      colorScheme: base.colorScheme.copyWith(
        primary: pri,
        onPrimary: onPri,
        secondary: NexlyColors.gold,
        onSecondary: NexlyColors.ink,
        surface: cardC,
        onSurface: fg,
        error: const Color(0xFFB3261E),
      ),
      textTheme: base.textTheme.apply(fontFamily: fontFamily, bodyColor: fg, displayColor: fg),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: fontFamily),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: pri, selectionColor: pri.withOpacity(0.3), selectionHandleColor: pri),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: pri, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pri,
          foregroundColor: onPri,
          elevation: 0,
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: bd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: pri)),
      checkboxTheme: base.checkboxTheme.copyWith(
          fillColor: MaterialStateProperty.resolveWith(
              (s) => s.contains(MaterialState.selected) ? pri : null)),
      switchTheme: base.switchTheme.copyWith(
          thumbColor: MaterialStateProperty.resolveWith(
              (s) => s.contains(MaterialState.selected) ? pri : null),
          trackColor: MaterialStateProperty.resolveWith(
              (s) => s.contains(MaterialState.selected) ? pri.withOpacity(0.5) : null)),
      tabBarTheme: base.tabBarTheme.copyWith(labelColor: pri, indicatorColor: pri),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
          backgroundColor: dark ? NexlyColors.darkCard2 : Colors.white,
          selectedItemColor: pri,
          unselectedItemColor: dark ? NexlyColors.darkMuted : NexlyColors.lightMuted),
      appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: dark ? NexlyColors.maroonDark : NexlyColors.maroon,
          foregroundColor: NexlyColors.cream),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: cardC,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), side: BorderSide(color: bd)),
      ),
    );
  }

  /// RTL when the app language is fa (explicit option, or system default fa).
  static bool isRtl() {
    var lang = '';
    try {
      lang = bind.mainGetLocalOption(key: kCommConfKeyLang);
    } catch (_) {}
    if (lang.isEmpty || lang == 'default') {
      try {
        lang = Platform.localeName;
      } catch (_) {}
    }
    final l = lang.toLowerCase();
    return l.startsWith('fa') || l.startsWith('ar');
  }

  static Widget directional(Widget? child) => Directionality(
      textDirection: isRtl() ? TextDirection.rtl : TextDirection.ltr,
      child: child ?? const SizedBox.shrink());
}
