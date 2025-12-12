import 'package:deep_link/services/link_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/visualizar_orcamento_page.dart';
import 'pages/visualizar_recibo_page.dart';
import 'pages/erro_page.dart';
import 'models/custom_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(const GestorfyClientApp());
}

class GestorfyClientApp extends StatefulWidget {
  const GestorfyClientApp({super.key});

  @override
  State<GestorfyClientApp> createState() => _GestorfyClientAppState();
}

class _GestorfyClientAppState extends State<GestorfyClientApp> {
  String? linkString;
  Map<String, String>? parametros;
  bool isLoading = true;

  Future<void> _getLink(String idLink) async {
    try {
      final link = await DeepLink.getLink(idLink);
      print('Deep Link recebido: $link');

      linkString = link.toJson().toString();

      // Extrair userId e documentoId do deep link
      // 🔄 Suporta tanto 'documentoId' (novo) quanto 'orcamentoId' (legado)
      if (link.parametrosPersonalizados?['userId'] != null) {
        // Tentar obter documentoId (novo padrão) ou orcamentoId (compatibilidade)
        String? docId = link.parametrosPersonalizados!['documentoId']
            ?.toString();
        if (docId == null || docId.isEmpty || docId == 'null') {
          docId = link.parametrosPersonalizados!['orcamentoId']?.toString();
          print('⚠️ Usando orcamentoId para compatibilidade: $docId');
        }

        if (docId != null && docId != 'null' && docId.isNotEmpty) {
          parametros = {
            'userId': link.parametrosPersonalizados!['userId'].toString(),
            'documentoId': docId,
            'tipoDocumento':
                link.parametrosPersonalizados!['tipoDocumento']?.toString() ??
                '',
            // Extrair cores personalizadas (ARGB format)
            'corPrimaria':
                link.parametrosPersonalizados!['corPrimaria']?.toString() ?? '',
            'corSecundaria':
                link.parametrosPersonalizados!['corSecundaria']?.toString() ??
                '',
            'corTerciaria':
                link.parametrosPersonalizados!['corTerciaria']?.toString() ??
                '',
            'corTextoSecundario':
                link.parametrosPersonalizados!['corTextoSecundario']
                    ?.toString() ??
                '',
            'corTextoTerciario':
                link.parametrosPersonalizados!['corTextoTerciario']
                    ?.toString() ??
                '',
          };

          print('✅ Parâmetros extraídos: $parametros');
        } else {
          print('❌ Deep link não contém documentoId válido');
          print('📋 Parâmetros recebidos: ${link.parametrosPersonalizados}');
        }
      } else {
        print('❌ Deep link não contém userId');
        print('📋 Parâmetros recebidos: ${link.parametrosPersonalizados}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar deep link: $e');
      linkString = 'Erro ao carregar link';
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    final currentUrl = Uri.base;

    // 🔧 Verificar se há parâmetros diretos na URL (modo WebView)
    if (currentUrl.queryParameters.containsKey('userId') &&
        currentUrl.queryParameters.containsKey('documentoId')) {
      print('✅ Usando parâmetros diretos da URL');
      parametros = currentUrl.queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Caso contrário, usar deep link (modo compartilhamento externo)
    print('🔗 Usando deep link');
    parametros = DeepLink.getQueryParametersFromUri(currentUrl);
    final idLink = DeepLink.getIdLinkFromUri(currentUrl);

    DeepLink.init(
      baseUrl: 'https://us-central1-deep-link-hub.cloudfunctions.net',
      apiToken: 'nLL73gzJdaxyYzlqzhls',
    );

    _getLink(idLink);
  }

  @override
  Widget build(BuildContext context) {
    // Se ainda está carregando, mostra loading
    if (isLoading) {
      return MaterialApp(
        title: 'Gestorfy - Visualizar Orçamento',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          dialogBackgroundColor: Colors.white,
          canvasColor: Colors.white,
        ),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Gestorfy - Visualizar Orçamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        dialogBackgroundColor: Colors.white,
        canvasColor: Colors.white,
      ),
      home: parametros != null ? _buildDocumentPage() : _buildErrorPage(),
    );
  }

  // Decide qual página mostrar baseado no tipoDocumento
  Widget _buildDocumentPage() {
    final tipoDocumento = parametros!['tipoDocumento'] ?? '';

    // Criar tema personalizado com as cores dos parâmetros
    final customTheme = CustomTheme.fromParameters(parametros!);

    print('🎨 Tema personalizado: $customTheme');

    // Exibir Recibo
    if (tipoDocumento == 'recibo') {
      return VisualizarReciboPage(
        userId: parametros!['userId'],
        reciboId: parametros!['documentoId'],
      );
    }

    // Exibir Orçamento (padrão)
    return VisualizarOrcamentoPage(
      userId: parametros!['userId'],
      orcamentoId: parametros!['documentoId'],
      tipoDocumento: tipoDocumento,
      customTheme: customTheme,
    );
  }

  // Página de erro
  Widget _buildErrorPage() {
    return const ErroPage(
      titulo: 'Link Inválido',
      mensagem:
          'O link fornecido não é válido. Verifique se o link está correto e completo.',
    );
  }
}

/* Map<String, String>? _extrairParametrosUrl() {
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
  } */
