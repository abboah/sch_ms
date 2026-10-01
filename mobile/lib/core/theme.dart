import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which portal the signed-in person is in. It picks the accent colour, as on the web.
enum Portal { parent, teacher }

/// Design tokens from docs/01-design-system.md: warm paper, ink, restrained colour; serif headings, mono figures.
@immutable
class Tokens extends ThemeExtension<Tokens> {
  const Tokens({
    required this.paper,
    required this.raised,
    required this.ink,
    required this.soft,
    required this.mute,
    required this.rule,
    required this.alert,
    required this.forest,
    required this.forestSoft,
    required this.brass,
    required this.brassSoft,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
  });

  final Color paper, raised, ink, soft, mute, rule, alert;
  final Color forest, forestSoft, brass, brassSoft;
  final Color accent, accentSoft, onAccent;

  static const _light = (
    paper: Color(0xFFE9EBE3), raised: Color(0xFFF4F5F0), ink: Color(0xFF1B2430), soft: Color(0xFF3C4650),
    mute: Color(0xFF5C6B66), rule: Color(0xFFC7CBBE), alert: Color(0xFF8C3B3B),
    forest: Color(0xFF2F5D50), forestSoft: Color(0xFFE1EAE5), brass: Color(0xFF96692A), brassSoft: Color(0xFFF1E6D2),
    onAccent: Color(0xFFF4F5F0),
  );
  static const _dark = (
    paper: Color(0xFF1A2027), raised: Color(0xFF212832), ink: Color(0xFFECEAE0), soft: Color(0xFFC7CCC2),
    mute: Color(0xFF9AA69E), rule: Color(0xFF3A4149), alert: Color(0xFFD98080),
    forest: Color(0xFF82C0A7), forestSoft: Color(0xFF212C28), brass: Color(0xFFD9A85C), brassSoft: Color(0xFF2E2A1E),
    onAccent: Color(0xFF1A2027),
  );

  factory Tokens.of(Brightness b, Portal portal) {
    final t = b == Brightness.dark ? _dark : _light;
    final forest = portal == Portal.teacher;
    return Tokens(
      paper: t.paper, raised: t.raised, ink: t.ink, soft: t.soft, mute: t.mute, rule: t.rule, alert: t.alert,
      forest: t.forest, forestSoft: t.forestSoft, brass: t.brass, brassSoft: t.brassSoft,
      accent: forest ? t.forest : t.brass,
      accentSoft: forest ? t.forestSoft : t.brassSoft,
      onAccent: t.onAccent,
    );
  }

  @override
  Tokens copyWith() => this;

  @override
  Tokens lerp(ThemeExtension<Tokens>? other, double t) => this;
}

extension TokensX on BuildContext {
  Tokens get tokens => Theme.of(this).extension<Tokens>()!;
}

/// Type: Fraunces for headings, Source Sans 3 for text, IBM Plex Mono for labels and figures.
class HrText {
  HrText._();

  /// Use Google Fonts. Tests set this to false so nothing tries to download a font.
  static bool webFonts = true;

  static TextStyle serif(double size, Color color, {FontWeight w = FontWeight.w600, bool? web}) =>
      (web ?? webFonts) ? GoogleFonts.fraunces(fontSize: size, fontWeight: w, color: color, height: 1.15) : TextStyle(fontFamily: 'serif', fontSize: size, fontWeight: w, color: color, height: 1.15);

  static TextStyle sans(double size, Color color, {FontWeight w = FontWeight.w400, bool? web}) =>
      (web ?? webFonts) ? GoogleFonts.sourceSans3(fontSize: size, fontWeight: w, color: color, height: 1.4) : TextStyle(fontSize: size, fontWeight: w, color: color, height: 1.4);

  static TextStyle mono(double size, Color color, {FontWeight w = FontWeight.w500, double spacing = 0, bool? web}) => (web ?? webFonts)
      ? GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: w, color: color, letterSpacing: spacing, fontFeatures: const [FontFeature.tabularFigures()])
      : TextStyle(fontFamily: 'monospace', fontSize: size, fontWeight: w, color: color, letterSpacing: spacing);
}

class HrTheme {
  HrTheme._();

  static ThemeData build(Brightness brightness, Portal portal) {
    final webFonts = HrText.webFonts;
    final t = Tokens.of(brightness, portal);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.forest,
      onSecondary: t.onAccent,
      error: t.alert,
      onError: t.onAccent,
      surface: t.raised,
      onSurface: t.ink,
      outline: t.rule,
    );
    final radius = BorderRadius.circular(3);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: c, width: w));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.paper,
      canvasColor: t.paper,
      dividerColor: t.rule,
      extensions: [t],
      textTheme: TextTheme(
        displaySmall: HrText.serif(36, t.ink, web: webFonts),
        headlineMedium: HrText.serif(28, t.ink, web: webFonts),
        headlineSmall: HrText.serif(22, t.ink, web: webFonts),
        titleLarge: HrText.serif(20, t.ink, web: webFonts),
        titleMedium: HrText.sans(16, t.ink, w: FontWeight.w600, web: webFonts),
        bodyLarge: HrText.sans(16, t.ink, web: webFonts),
        bodyMedium: HrText.sans(15, t.ink, web: webFonts),
        bodySmall: HrText.sans(13, t.mute, web: webFonts),
        labelLarge: HrText.sans(15, t.ink, w: FontWeight.w600, web: webFonts),
        labelSmall: HrText.mono(11, t.mute, spacing: 1.0, web: webFonts),
      ),
      appBarTheme: AppBarTheme(backgroundColor: t.paper, foregroundColor: t.ink, elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
      cardTheme: CardThemeData(color: t.raised, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: t.rule))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(t.rule),
        enabledBorder: border(t.rule),
        focusedBorder: border(t.accent, 2),
        errorBorder: border(t.alert),
        hintStyle: HrText.sans(15, t.mute, web: webFonts),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: HrText.sans(15, t.onAccent, w: FontWeight.w600, web: webFonts),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: t.rule),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: HrText.sans(15, t.ink, w: FontWeight.w600, web: webFonts),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: t.accent, minimumSize: const Size(0, 44), textStyle: HrText.sans(15, t.accent, w: FontWeight.w600, web: webFonts))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: t.raised, modalBackgroundColor: t.raised, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
      snackBarTheme: SnackBarThemeData(backgroundColor: t.ink, contentTextStyle: HrText.sans(14, t.paper, web: webFonts), behavior: SnackBarBehavior.floating),
      checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.accent : null), checkColor: WidgetStatePropertyAll(t.onAccent)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.onAccent : t.mute),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.accent : t.rule),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.accent, linearTrackColor: t.rule),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.raised,
        indicatorColor: t.accentSoft,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => HrText.sans(11, s.contains(WidgetState.selected) ? t.accent : t.mute, w: FontWeight.w600, web: webFonts)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? t.accent : t.mute)),
      ),
    );
  }
}
