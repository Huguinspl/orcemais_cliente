import 'package:flutter/material.dart';

/// Modelo para armazenar cores personalizadas do PDF
class CustomTheme {
  final Color? primary;
  final Color? secondaryContainer;
  final Color? tertiaryContainer;
  final Color? onSecondaryContainer;
  final Color? onTertiaryContainer;

  CustomTheme({
    this.primary,
    this.secondaryContainer,
    this.tertiaryContainer,
    this.onSecondaryContainer,
    this.onTertiaryContainer,
  });

  /// Converte cores ARGB (int) vindas dos parâmetros para Color
  factory CustomTheme.fromParameters(Map<String, String> params) {
    return CustomTheme(
      primary: _parseColor(params['corPrimaria']),
      secondaryContainer: _parseColor(params['corSecundaria']),
      tertiaryContainer: _parseColor(params['corTerciaria']),
      onSecondaryContainer: _parseColor(params['corTextoSecundario']),
      onTertiaryContainer: _parseColor(params['corTextoTerciario']),
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
    );
  }

  /// Verifica se há cores personalizadas
  bool get hasCustomColors {
    return primary != null ||
        secondaryContainer != null ||
        tertiaryContainer != null ||
        onSecondaryContainer != null ||
        onTertiaryContainer != null;
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

  @override
  String toString() {
    return 'CustomTheme(primary: $primary, secondaryContainer: $secondaryContainer, tertiaryContainer: $tertiaryContainer)';
  }
}
