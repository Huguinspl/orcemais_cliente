import 'package:intl/intl.dart';

class Formatters {
  // Formata valor monetário (BRL)
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Formata data
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  // Formata data e hora
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  // Formata telefone
  static String formatPhone(String phone) {
    if (phone.isEmpty) return '';

    // Remove caracteres não numéricos
    String numbers = phone.replaceAll(RegExp(r'\D'), '');

    if (numbers.length == 11) {
      // Celular: (XX) XXXXX-XXXX
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      // Fixo: (XX) XXXX-XXXX
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }

    return phone;
  }

  // Formata CPF/CNPJ
  static String formatCpfCnpj(String document) {
    if (document.isEmpty) return '';

    String numbers = document.replaceAll(RegExp(r'\D'), '');

    if (numbers.length == 11) {
      // CPF: XXX.XXX.XXX-XX
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
    } else if (numbers.length == 14) {
      // CNPJ: XX.XXX.XXX/XXXX-XX
      return '${numbers.substring(0, 2)}.${numbers.substring(2, 5)}.${numbers.substring(5, 8)}/${numbers.substring(8, 12)}-${numbers.substring(12)}';
    }

    return document;
  }
}
