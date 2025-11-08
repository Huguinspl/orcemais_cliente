import 'package:flutter/material.dart';

class AppConstants {
  // Cores
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Cores de status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return successColor;
      case 'recusado':
      case 'cancelado':
        return errorColor;
      case 'enviado':
        return primaryColor;
      case 'aberto':
      default:
        return Colors.grey;
    }
  }

  // Ícones de tipo de item
  static IconData getTipoItemIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'servico':
        return Icons.build;
      case 'peca':
      case 'produto':
        return Icons.inventory_2;
      default:
        return Icons.description;
    }
  }
}
