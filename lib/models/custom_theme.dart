import 'package:flutter/material.dart';

/// Modelo para armazenar cores personalizadas do PDF
class CustomTheme {
  final Color? primary;
  final Color? secondaryContainer;
  final Color? tertiaryContainer;
  final Color? onSecondaryContainer;
  final Color? onTertiaryContainer;

  // Cores das novas seções
  final Color? laudoBackground;
  final Color? laudoText;
  final Color? garantiaBackground;
  final Color? garantiaText;
  final Color? contratoBackground;
  final Color? contratoText;
  final Color? fotosBackground;
  final Color? fotosText;
  final Color? pagamentoBackground;
  final Color? pagamentoText;
  final Color? valoresBackground;
  final Color? valoresText;

  CustomTheme({
    this.primary,
    this.secondaryContainer,
    this.tertiaryContainer,
    this.onSecondaryContainer,
    this.onTertiaryContainer,
    this.laudoBackground,
    this.laudoText,
    this.garantiaBackground,
    this.garantiaText,
    this.contratoBackground,
    this.contratoText,
    this.fotosBackground,
    this.fotosText,
    this.pagamentoBackground,
    this.pagamentoText,
    this.valoresBackground,
    this.valoresText,
  });

  /// Converte cores ARGB (int) vindas dos parâmetros para Color
  factory CustomTheme.fromParameters(Map<String, String> params) {
    return CustomTheme(
      primary: _parseColor(params['corPrimaria']),
      secondaryContainer: _parseColor(params['corSecundaria']),
      tertiaryContainer: _parseColor(params['corTerciaria']),
      onSecondaryContainer: _parseColor(params['corTextoSecundario']),
      onTertiaryContainer: _parseColor(params['corTextoTerciario']),
      laudoBackground: _parseColor(params['laudoBackground']),
      laudoText: _parseColor(params['laudoText']),
      garantiaBackground: _parseColor(params['garantiaBackground']),
      garantiaText: _parseColor(params['garantiaText']),
      contratoBackground: _parseColor(params['contratoBackground']),
      contratoText: _parseColor(params['contratoText']),
      fotosBackground: _parseColor(params['fotosBackground']),
      fotosText: _parseColor(params['fotosText']),
      pagamentoBackground: _parseColor(params['pagamentoBackground']),
      pagamentoText: _parseColor(params['pagamentoText']),
      valoresBackground: _parseColor(params['valoresBackground']),
      valoresText: _parseColor(params['valoresText']),
    );
  }

  /// Converte string ARGB para Color
  /// Formato esperado: "4294198070" (int ARGB)
  static Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      final intValue = int.parse(colorString);
      return Color(intValue);
    } catch (e) {
      print('❌ Erro ao converter cor: $colorString - $e');
      return null;
    }
  }

  /// Retorna cores padrão se nenhuma cor personalizada foi fornecida
  static CustomTheme get defaultTheme {
    return CustomTheme(
      primary: Colors.blue.shade600,
      secondaryContainer: Colors.blue.shade50,
      tertiaryContainer: Colors.blue.shade100,
      onSecondaryContainer: Colors.blue.shade900,
      onTertiaryContainer: Colors.blue.shade900,
      laudoBackground: const Color(0xFFF5F5F5),
      laudoText: const Color(0xFF212121),
      garantiaBackground: const Color(0xFFE8F5E9),
      garantiaText: const Color(0xFF1B5E20),
      contratoBackground: const Color(0xFFFFF3E0),
      contratoText: const Color(0xFFE65100),
      fotosBackground: const Color(0xFFE3F2FD),
      fotosText: const Color(0xFF0D47A1),
      pagamentoBackground: const Color(0xFFF3E5F5),
      pagamentoText: const Color(0xFF4A148C),
      valoresBackground: const Color(0xFFE0F2F1),
      valoresText: const Color(0xFF004D40),
    );
  }

  /// Verifica se há cores personalizadas
  bool get hasCustomColors {
    return primary != null ||
        secondaryContainer != null ||
        tertiaryContainer != null ||
        onSecondaryContainer != null ||
        onTertiaryContainer != null ||
        laudoBackground != null ||
        laudoText != null ||
        garantiaBackground != null ||
        garantiaText != null ||
        contratoBackground != null ||
        contratoText != null ||
        fotosBackground != null ||
        fotosText != null ||
        pagamentoBackground != null ||
        pagamentoText != null ||
        valoresBackground != null ||
        valoresText != null;
  }

  /// Retorna a cor primária ou a padrão
  Color get primaryColor => primary ?? Colors.blue.shade600;

  Color get secondaryContainerColor =>
      secondaryContainer ?? Colors.blue.shade50;

  Color get tertiaryContainerColor => tertiaryContainer ?? Colors.blue.shade100;

  Color get onSecondaryContainerColor =>
      onSecondaryContainer ?? Colors.blue.shade900;

  Color get onTertiaryContainerColor =>
      onTertiaryContainer ?? Colors.blue.shade900;

  // Getters para as novas cores
  Color get laudoBackgroundColor => laudoBackground ?? const Color(0xFFF5F5F5);
  Color get laudoTextColor => laudoText ?? const Color(0xFF212121);

  Color get garantiaBackgroundColor =>
      garantiaBackground ?? const Color(0xFFE8F5E9);
  Color get garantiaTextColor => garantiaText ?? const Color(0xFF1B5E20);

  Color get contratoBackgroundColor =>
      contratoBackground ?? const Color(0xFFFFF3E0);
  Color get contratoTextColor => contratoText ?? const Color(0xFFE65100);

  Color get fotosBackgroundColor => fotosBackground ?? const Color(0xFFE3F2FD);
  Color get fotosTextColor => fotosText ?? const Color(0xFF0D47A1);

  Color get pagamentoBackgroundColor =>
      pagamentoBackground ?? const Color(0xFFF3E5F5);
  Color get pagamentoTextColor => pagamentoText ?? const Color(0xFF4A148C);

  Color get valoresBackgroundColor =>
      valoresBackground ?? const Color(0xFFE0F2F1);
  Color get valoresTextColor => valoresText ?? const Color(0xFF004D40);

  @override
  String toString() {
    return 'CustomTheme(primary: $primary, secondaryContainer: $secondaryContainer, tertiaryContainer: $tertiaryContainer)';
  }
}
