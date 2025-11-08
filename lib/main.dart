import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:html' as html;
import 'firebase_options.dart';
import 'pages/visualizar_orcamento_page.dart';
import 'pages/erro_page.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(const GestorfyClientApp());
}

class GestorfyClientApp extends StatelessWidget {
  const GestorfyClientApp({super.key});

  Map<String, String>? _extrairParametrosUrl() {
    try {
      final url = html.window.location.href;
      final uri = Uri.parse(url);

      // Exemplo: /orcamento/tdB0QRkOfiMfRQAMykXjasZbIXq2-9uaQfBGgae5TcuPjqgts
      final path = uri.path;

      if (!path.contains('/orcamento/')) {
        return null;
      }

      // Extrair a parte após /orcamento/
      final parametros = path.split('/orcamento/').last;

      // Separar userId e orcamentoId pelo último traço
      final ultimoTracoIndex = parametros.lastIndexOf('-');

      if (ultimoTracoIndex == -1) {
        return null;
      }

      final userId = parametros.substring(0, ultimoTracoIndex);
      final orcamentoId = parametros.substring(ultimoTracoIndex + 1);

      if (userId.isEmpty || orcamentoId.isEmpty) {
        return null;
      }

      return {'userId': userId, 'orcamentoId': orcamentoId};
    } catch (e) {
      print('Erro ao extrair parâmetros da URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parametros = _extrairParametrosUrl();

    return MaterialApp(
      title: 'Gestorfy - Visualizar Orçamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
      ),
      home: parametros != null
          ? VisualizarOrcamentoPage(
              userId: parametros['userId'],
              orcamentoId: parametros['orcamentoId'],
            )
          : const ErroPage(
              titulo: 'Link Inválido',
              mensagem:
                  'O link fornecido não é válido. Verifique se o link está correto e completo.',
            ),
    );
  }
}
