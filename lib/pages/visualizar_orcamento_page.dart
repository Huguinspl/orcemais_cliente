import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/orcamento.dart';
import '../models/business_info.dart';
import '../models/custom_theme.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/business_header.dart';
import '../widgets/item_card.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../utils/modern_colors.dart';

class VisualizarOrcamentoPage extends StatefulWidget {
  final String? userId;
  final String? orcamentoId;
  final String? tipoDocumento;
  final CustomTheme? customTheme;

  const VisualizarOrcamentoPage({
    super.key,
    this.userId,
    this.orcamentoId,
    this.tipoDocumento,
    this.customTheme,
  });

  @override
  State<VisualizarOrcamentoPage> createState() =>
      _VisualizarOrcamentoPageState();
}

class _VisualizarOrcamentoPageState extends State<VisualizarOrcamentoPage> {
  bool _isLoading = true;
  Orcamento? _orcamento;
  BusinessInfo? _businessInfo;
  String? _errorMessage;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.orcamentoId == null) {
        throw Exception('ID do orçamento não informado');
      }

      print('Carregando dados...');
      print('   orcamentoId: ${widget.orcamentoId}');

      // OTIMIZAÇÃO: Tenta primeiro buscar do snapshot (1 leitura rápida)
      final snapshot = await _firestoreService.getSharedDocument(widget.orcamentoId!);

      if (snapshot != null) {
        // Snapshot encontrado! Carregamento ultrarrápido
        print('Carregamento rápido via snapshot!');

        final orcamentoData = snapshot['orcamento'] as Map<String, dynamic>;
        final businessData = snapshot['businessInfo'] as Map<String, dynamic>;
        final businessInfo = BusinessInfo.fromMap(businessData);
        
        // Pré-carrega a logo em paralelo para evitar delay visual
        if (businessInfo.logoUrl != null && businessInfo.logoUrl!.isNotEmpty && mounted) {
          precacheImage(NetworkImage(businessInfo.logoUrl!), context);
        }

        setState(() {
          _orcamento = Orcamento.fromMap(widget.orcamentoId!, orcamentoData);
          _businessInfo = businessInfo;
          _isLoading = false;
        });

        print('Dados carregados via snapshot!');
        return;
      }

      // Fallback: busca tradicional (2 leituras) para links antigos
      print('Usando fallback tradicional...');

      if (widget.userId == null) {
        throw Exception('Parâmetros inválidos');
      }

      final results = await Future.wait([
        _firestoreService.getOrcamento(widget.userId!, widget.orcamentoId!),
        _firestoreService.getBusinessInfo(widget.userId!),
      ]);

      final orcamento = results[0] as Orcamento?;
      final businessInfo = results[1] as BusinessInfo?;

      if (orcamento == null) {
        throw Exception('Orçamento não encontrado ou não está disponível');
      }

      if (businessInfo == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Pré-carrega a logo em paralelo para evitar delay visual
      if (businessInfo.logoUrl != null && businessInfo.logoUrl!.isNotEmpty && mounted) {
        precacheImage(NetworkImage(businessInfo.logoUrl!), context);
      }

      setState(() {
        _orcamento = orcamento;
        _businessInfo = businessInfo;
        _isLoading = false;
      });

      print('Dados carregados com sucesso!');
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _isLoading || _orcamento == null
          ? null
          : AppBar(
              title: const Text(
                'Orçamento',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              toolbarHeight: 80,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                      Color(0xFF1E88E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              foregroundColor: Colors.white,
            ),
      body: _buildBody(),
      bottomNavigationBar: _isLoading || _orcamento == null
          ? null
          : _buildBottomBar(context),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando orçamento...');
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_orcamento == null || _businessInfo == null) {
      return const Center(child: Text('Orçamento não encontrado'));
    }

    final primaryColor = Color(0xFF1976D2);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Card com dados do negócio
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildBusinessHeader(context),
            ),
          ),

          // Descrição da empresa com design moderno
          if (_businessInfo!.descricao != null &&
              _businessInfo!.descricao!.isNotEmpty) ...[
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: Text(
                _businessInfo!.descricao!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],

          // Card principal com design moderno
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dados do Cliente
                _buildSection(
                  icon: Icons.person_outline,
                  title: 'Dados do Cliente',
                  child: _buildClientInfoWeb(context),
                ),
                const Divider(height: 1),

                // Itens do Orçamento
                _buildSection(
                  icon: Icons.list_alt,
                  title: 'Itens do Orçamento',
                  child: _buildItensListWeb(context),
                ),
                const Divider(height: 1),

                // Forma de Pagamento
                if (_orcamento!.metodoPagamento != null &&
                    _orcamento!.metodoPagamento!.isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.payment,
                    title: 'Forma de Pagamento',
                    child: _buildPagamentoWeb(context),
                  ),
                  const Divider(height: 1),
                ],

                // Laudo Técnico
                if (_orcamento!.laudoTecnico != null &&
                    _orcamento!.laudoTecnico!.trim().isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.engineering,
                    title: 'Laudo Técnico',
                    child: _buildTextContent(_orcamento!.laudoTecnico!),
                  ),
                  const Divider(height: 1),
                ],

                // Condições Contratuais
                if (_orcamento!.condicoesContratuais != null &&
                    _orcamento!.condicoesContratuais!.trim().isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.description,
                    title: 'Condições Contratuais',
                    child: _buildTextContent(_orcamento!.condicoesContratuais!),
                  ),
                  const Divider(height: 1),
                ],

                // Garantia
                if (_orcamento!.garantia != null &&
                    _orcamento!.garantia!.trim().isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.verified_user,
                    title: 'Garantia',
                    child: _buildTextContent(_orcamento!.garantia!),
                  ),
                  const Divider(height: 1),
                ],

                // Informações Adicionais
                if (_orcamento!.informacoesAdicionais != null &&
                    _orcamento!.informacoesAdicionais!.trim().isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.info_outline,
                    title: 'Informações Adicionais',
                    child: _buildTextContent(
                      _orcamento!.informacoesAdicionais!,
                    ),
                  ),
                  const Divider(height: 1),
                ],

                // Fotos
                if (_orcamento!.fotos != null &&
                    _orcamento!.fotos!.isNotEmpty) ...[
                  _buildSection(
                    icon: Icons.photo_library,
                    title: 'Fotos',
                    child: _buildFotosGridWeb(context),
                  ),
                  const Divider(height: 1),
                ],

                // Resumo Financeiro (no final, antes da assinatura)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  child: _buildResumoFinanceiroWeb(context),
                ),

                // Assinatura
                if (_businessInfo!.assinaturaUrl != null &&
                    _businessInfo!.assinaturaUrl!.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildAssinaturaWeb(context),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            color: Colors.grey.shade100,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Orçamento gerado por',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _businessInfo!.nomeEmpresa,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSection() {
    final cliente = _orcamento!.cliente;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ModernColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: ModernColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dados do Cliente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nome', cliente.nome),
                  if (cliente.celular.isNotEmpty)
                    _buildInfoRow(
                      'Celular',
                      Formatters.formatPhone(cliente.celular),
                    ),
                  if (cliente.email.isNotEmpty)
                    _buildInfoRow('Email', cliente.email),
                  if (cliente.cpfCnpj.isNotEmpty)
                    _buildInfoRow(
                      'CPF/CNPJ',
                      Formatters.formatCpfCnpj(cliente.cpfCnpj),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: ModernColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Itens do Orçamento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...(_orcamento!.itens.map((item) => ItemCard(item: item))),
      ],
    );
  }

  Widget _buildResumoFinanceiro() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ModernColors.valoresBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernColors.valoresIcon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: ModernColors.valoresText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumo Financeiro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.valoresText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Valores em card branco
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildResumoRow(
                    'Subtotal',
                    Formatters.formatCurrency(_orcamento!.subtotal),
                    color: ModernColors.valoresText,
                  ),
                  if (_orcamento!.desconto > 0) ...[
                    const SizedBox(height: 12),
                    _buildResumoRow(
                      'Desconto',
                      '- ${Formatters.formatCurrency(_orcamento!.desconto)}',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 1.5),
                  ),
                  _buildResumoRow(
                    'VALOR TOTAL',
                    Formatters.formatCurrency(_orcamento!.valorTotal),
                    isBold: true,
                    fontSize: 24,
                    color: ModernColors.valoresText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagamentoSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ModernColors.pagamentoBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Forma de Pagamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Método', _orcamento!.metodoPagamento!),
                  if (_orcamento!.parcelas != null) ...[
                    const Divider(height: 16),
                    _buildInfoRow('Parcelamento', '${_orcamento!.parcelas}x'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAdicionaisSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informações Adicionais',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _orcamento!.informacoesAdicionais!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSection(String title, String content) {
    // Cores modernas por seção
    IconData icon;
    switch (title) {
      case 'Laudo Técnico':
        icon = Icons.description;
        break;
      case 'Garantia':
        icon = Icons.verified_user;
        break;
      case 'Condições Contratuais':
        icon = Icons.gavel;
        break;
      default:
        icon = Icons.article;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotosSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fotos do Orçamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _orcamento!.fotos!.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.network(
                      _orcamento!.fotos![index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _businessInfo!.nomeEmpresa,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatPhone(_businessInfo!.telefone),
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            _businessInfo!.emailEmpresa,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Emitido em ${Formatters.formatDate(DateTime.now())}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    final textColor = color ?? Colors.grey[800]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _recusarOrcamento() {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Color(0xFFEF4444)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Recusar Orçamento?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tem certeza que deseja recusar este orçamento?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Por favor, informe o motivo da recusa:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: motivoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Preço acima do esperado, prazo muito longo...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final motivo = motivoController.text.trim();

              if (motivo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Por favor, informe o motivo da recusa',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              await _atualizarStatusOrcamento('Recusado', motivoRecusa: motivo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Recusar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _aprovarOrcamento() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Aprovar Orçamento?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Confirma a aprovação deste orçamento? O prestador será notificado da sua decisão.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _atualizarStatusOrcamento('Aprovado');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aprovar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD FIXO INFERIOR MODERNIZADO ====================

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Valor Total com gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1976D2).withOpacity(0.15),
                    Color(0xFF1976D2).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF1976D2).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1976D2).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VALOR TOTAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1976D2).withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(_orcamento!.valorTotal),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1976D2),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Botões modernizados com gradiente
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade200.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _recusarOrcamento(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.close_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Recusar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _aprovarOrcamento(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Aprovar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NOVOS MÉTODOS PARA LAYOUT IDÊNTICO ====================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1976D2).withOpacity(0.1),
                      Color(0xFF1976D2).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: Color(0xFF1976D2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBusinessHeader(BuildContext context) {
    return Column(
      children: [
        // Logo
        if (_businessInfo!.logoUrl != null &&
            _businessInfo!.logoUrl!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF1976D2).withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Image.network(
              _businessInfo!.logoUrl!,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.business, size: 80, color: Color(0xFF1976D2)),
            ),
          ),
        const SizedBox(height: 20),

        // Nome da empresa
        Text(
          _businessInfo!.nomeEmpresa,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),

        // Ramo de atividade
        if (_businessInfo!.ramo.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _businessInfo!.ramo,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Informações de contato
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_businessInfo!.telefone.isNotEmpty)
                _buildClickablePhone(_businessInfo!.telefone),
              if (_businessInfo!.cnpj.isNotEmpty) ...[
                if (_businessInfo!.telefone.isNotEmpty)
                  const SizedBox(height: 8),
                _buildInfoRowBusiness(
                  Icons.badge_outlined,
                  Formatters.formatCpfCnpj(_businessInfo!.cnpj),
                ),
              ],
              if (_businessInfo!.emailEmpresa.isNotEmpty) ...[
                if (_businessInfo!.telefone.isNotEmpty ||
                    _businessInfo!.cnpj.isNotEmpty)
                  const SizedBox(height: 8),
                _buildInfoRowBusiness(Icons.email, _businessInfo!.emailEmpresa),
              ],
              if (_businessInfo!.endereco.isNotEmpty) ...[
                if (_businessInfo!.telefone.isNotEmpty ||
                    _businessInfo!.cnpj.isNotEmpty ||
                    _businessInfo!.emailEmpresa.isNotEmpty)
                  const SizedBox(height: 8),
                _buildInfoRowBusiness(
                  Icons.location_on,
                  _businessInfo!.endereco,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickablePhone(String telefone) {
    return InkWell(
      onTap: () => _abrirWhatsApp(telefone),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/iconzap-principal.png', width: 18, height: 18),
            const SizedBox(width: 8),
            Text(
              Formatters.formatPhone(telefone),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF25D366),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 14, color: Color(0xFF25D366)),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirWhatsApp(String telefone) async {
    String numbers = telefone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/55$numbers');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoRowBusiness(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoWeb(BuildContext context) {
    final items = [
      if (_orcamento!.cliente.nome.isNotEmpty)
        {
          'icon': Icons.person_outline,
          'label': 'Nome',
          'value': _orcamento!.cliente.nome,
        },
      if (_orcamento!.cliente.celular.isNotEmpty)
        {
          'icon': Icons.phone_android,
          'label': 'Celular',
          'value': _orcamento!.cliente.celular,
        },
      if (_orcamento!.cliente.telefone.isNotEmpty)
        {
          'icon': Icons.phone,
          'label': 'Telefone',
          'value': _orcamento!.cliente.telefone,
        },
      if (_orcamento!.cliente.email.isNotEmpty)
        {
          'icon': Icons.email_outlined,
          'label': 'Email',
          'value': _orcamento!.cliente.email,
        },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        children: items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: Color(0xFF1976D2),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item['label']}: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    item['value'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildClientInfoGroupCard({
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: Color(0xFF1976D2),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['value'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClientInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          // Ícone compacto
          Icon(icon, color: Color(0xFF1976D2), size: 18),
          const SizedBox(width: 10),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWeb(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItensListWeb(BuildContext context) {
    return Column(
      children: List.generate(_orcamento!.itens.length, (index) {
        final item = _orcamento!.itens[index];
        return _buildItemWeb(index + 1, item);
      }),
    );
  }

  Widget _buildItemWeb(int numero, Map<String, dynamic> item) {
    final nome = item['nome'] ?? '---';
    final descricao = item['descricao'];
    final quantidade = double.tryParse(item['quantidade'].toString()) ?? 1.0;
    final preco = double.tryParse(item['preco'].toString()) ?? 0.0;
    final subtotal = (quantidade * preco).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho do item
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF1976D2).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Número do item
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nome do item
                Expanded(
                  child: Text(
                    nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do item
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descrição (se existir)
                if (descricao != null && descricao.toString().isNotEmpty) ...[
                  Text(
                    descricao.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 16),
                ],

                // Detalhes organizados em grid
                Row(
                  children: [
                    // Quantidade
                    Expanded(
                      child: _buildInfoBox(
                        label: 'Quantidade',
                        value: quantidade.toStringAsFixed(
                          quantidade.truncateToDouble() == quantidade ? 0 : 2,
                        ),
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Preço unitário
                    Expanded(
                      child: _buildInfoBox(
                        label: 'Preço Unit.',
                        value: Formatters.formatCurrency(preco),
                        icon: Icons.payments_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rodapé com valor total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF1976D2).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total dos Itens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(subtotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPagamentoWeb(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRowWeb('Método', _orcamento!.metodoPagamento!),
        if (_orcamento!.parcelas != null)
          _buildInfoRowWeb('Parcelamento', '${_orcamento!.parcelas}x'),
      ],
    );
  }

  Widget _buildTextContent(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade700),
    );
  }

  Widget _buildFotosGridWeb(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _orcamento!.fotos!.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _orcamento!.fotos![index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResumoFinanceiroWeb(BuildContext context) {
    // Calcular custos adicionais
    double custoTotal = 0.0;
    for (var item in _orcamento!.itens) {
      final custo = double.tryParse(item['custo']?.toString() ?? '0') ?? 0.0;
      custoTotal += custo;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Fundo cinza claro igual à página
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1976D2).withOpacity(0.08),
                  const Color(0xFF1976D2).withOpacity(0.04),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Resumo Financeiro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Subtotal
                _buildFinanceiroRowCard(
                  'Subtotal',
                  _orcamento!.subtotal,
                  Icons.calculate_outlined,
                  Colors.grey.shade700,
                ),

                // Custos Adicionais (se houver)
                if (custoTotal > 0) ...[
                  const SizedBox(height: 10),
                  _buildFinanceiroRowCard(
                    'Custos Adicionais',
                    custoTotal,
                    Icons.build_outlined,
                    Colors.grey.shade700,
                  ),
                ],

                // Desconto (se houver)
                if (_orcamento!.desconto > 0) ...[
                  const SizedBox(height: 10),
                  _buildFinanceiroRowCard(
                    'Desconto',
                    _orcamento!.desconto,
                    Icons.local_offer_outlined,
                    Colors.red.shade600,
                    isNegative: true,
                  ),
                ],

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 12),

                // Total destacado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1976D2).withOpacity(0.12),
                        const Color(0xFF1976D2).withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1976D2,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Flexible(
                              child: Text(
                                'VALOR TOTAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1976D2),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          Formatters.formatCurrency(_orcamento!.valorTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1976D2),
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceiroRowCard(
    String label,
    double valor,
    IconData icon,
    Color cor, {
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cor),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
          Text(
            '${isNegative ? '-' : ''}${Formatters.formatCurrency(valor)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red.shade600 : Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceiroRow(
    String label,
    double valor, {
    bool isNegative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          '${isNegative ? '-' : ''}${Formatters.formatCurrency(valor)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAssinaturaWeb(BuildContext context) {
    return Column(
      children: [
        Image.network(
          _businessInfo!.assinaturaUrl!,
          height: 60,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          _businessInfo!.nomeEmpresa,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==================== FIM DOS NOVOS MÉTODOS ====================

  Future<void> _enviarMensagemAprovacao() async {
    try {
      // Preparar mensagem
      final nomeCliente = _orcamento!.cliente.nome;
      final numeroOrcamento = _orcamento!.numero;
      final valorTotal = Formatters.formatCurrency(_orcamento!.valorTotal);

      final mensagem =
          '✅ *Orçamento Aprovado!*\n\n'
          'Olá! O orçamento foi aprovado por $nomeCliente.\n\n'
          '💰 Valor: $valorTotal\n\n'
          'Acesse o sistema para mais detalhes.';

      // Codificar mensagem para URL
      final mensagemCodificada = Uri.encodeComponent(mensagem);

      // Limpar telefone e adicionar código do Brasil
      String numbers = _businessInfo!.telefone.replaceAll(RegExp(r'\D'), '');

      // Abrir WhatsApp com mensagem
      final url = Uri.parse(
        'https://wa.me/55$numbers?text=$mensagemCodificada',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erro ao enviar mensagem WhatsApp: $e');
    }
  }

  Future<void> _enviarMensagemRecusa(String motivo) async {
    try {
      // Preparar mensagem
      final nomeCliente = _orcamento!.cliente.nome;
      final numeroOrcamento = _orcamento!.numero;
      final valorTotal = Formatters.formatCurrency(_orcamento!.valorTotal);

      final mensagem =
          '❌ *Orçamento Recusado*\n\n'
          'Olá! O orçamento foi recusado por $nomeCliente.\n\n'
          '💰 Valor: $valorTotal\n\n'
          '📝 *Motivo da recusa:*\n$motivo\n\n'
          'Acesse o sistema para mais detalhes.';

      // Codificar mensagem para URL
      final mensagemCodificada = Uri.encodeComponent(mensagem);

      // Limpar telefone e adicionar código do Brasil
      String numbers = _businessInfo!.telefone.replaceAll(RegExp(r'\D'), '');

      // Abrir WhatsApp com mensagem
      final url = Uri.parse(
        'https://wa.me/55$numbers?text=$mensagemCodificada',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erro ao enviar mensagem WhatsApp: $e');
    }
  }

  Future<void> _atualizarStatusOrcamento(
    String novoStatus, {
    String? motivoRecusa,
  }) async {
        // Mostrar loading com fundo transparente
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Atualizando status...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Atualizar status no Firestore
      await _firestoreService.updateOrcamentoStatus(
        widget.userId!,
        widget.orcamentoId!,
        novoStatus,
      );

      // Fechar loading
      if (mounted) Navigator.pop(context);

      // Enviar mensagem WhatsApp conforme o status
      if (_businessInfo != null && _businessInfo!.telefone.isNotEmpty) {
        if (novoStatus == 'Aprovado') {
          await _enviarMensagemAprovacao();
        } else if (novoStatus == 'Recusado' &&
            motivoRecusa != null &&
            motivoRecusa.isNotEmpty) {
          await _enviarMensagemRecusa(motivoRecusa);
        }
      }

      // Mostrar mensagem de sucesso
      if (mounted) {
        final cor = novoStatus == 'Aprovado'
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  novoStatus == 'Aprovado' ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Orçamento ${novoStatus.toLowerCase()} com sucesso!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: cor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Atualizar estado local
        setState(() {
          _orcamento = _orcamento!.copyWith(status: novoStatus);
        });
      }
    } catch (e) {
      // Fechar loading
      if (mounted) Navigator.pop(context);

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao atualizar status: ${e.toString()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
