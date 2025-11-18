import 'package:flutter/material.dart';
import '../models/orcamento.dart';
import '../models/business_info.dart';
import '../models/custom_theme.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/business_header.dart';
import '../widgets/orcamento_card.dart';
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
      if (widget.userId == null || widget.orcamentoId == null) {
        throw Exception('Parâmetros inválidos');
      }

      print('📊 Carregando dados...');
      print('   userId: ${widget.userId}');
      print('   orcamentoId: ${widget.orcamentoId}');

      // Buscar dados em paralelo para melhor performance
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

      setState(() {
        _orcamento = orcamento;
        _businessInfo = businessInfo;
        _isLoading = false;
      });

      print('✅ Dados carregados com sucesso!');
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: AppBar(
        title: const Text(
          'Orçamento',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: ModernColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBody(),
          _buildBottomCard(),
        ],
      ),
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

    // Tema personalizado
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Cabeçalho da empresa
          BusinessHeader(businessInfo: _businessInfo!, customTheme: theme),

          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card do orçamento (moderno, sem numeração)
                OrcamentoCard(
                  orcamento: _orcamento!,
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 16),

                // Informações do cliente
                _buildClienteSection(),

                const SizedBox(height: 24),

                // Lista de itens
                _buildItensSection(),

                const SizedBox(height: 24),

                // Resumo financeiro
                _buildResumoFinanceiro(),

                const SizedBox(height: 24),

                // Informações de pagamento
                if (_orcamento!.metodoPagamento != null)
                  _buildPagamentoSection(),

                // Laudo Técnico
                if (_orcamento!.laudoTecnico != null &&
                    _orcamento!.laudoTecnico!.isNotEmpty)
                  _buildTextSection('Laudo Técnico', _orcamento!.laudoTecnico!),

                // Garantia
                if (_orcamento!.garantia != null &&
                    _orcamento!.garantia!.isNotEmpty)
                  _buildTextSection('Garantia', _orcamento!.garantia!),

                // Condições Contratuais
                if (_orcamento!.condicoesContratuais != null &&
                    _orcamento!.condicoesContratuais!.isNotEmpty)
                  _buildTextSection(
                    'Condições Contratuais',
                    _orcamento!.condicoesContratuais!,
                  ),

                // Fotos
                if (_orcamento!.fotos != null && _orcamento!.fotos!.isNotEmpty)
                  _buildFotosSection(),

                // Informações adicionais
                if (_orcamento!.informacoesAdicionais != null &&
                    _orcamento!.informacoesAdicionais!.isNotEmpty)
                  _buildInfoAdicionaisSection(),

                const SizedBox(height: 32),

                // Rodapé
                _buildFooter(),

                // Espaço para o card fixo inferior
                const SizedBox(height: 200),
              ],
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
                        'Celular', Formatters.formatPhone(cliente.celular)),
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
                    color: ModernColors.pagamentoIcon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: ModernColors.pagamentoText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Forma de Pagamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.pagamentoText,
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
                  _buildInfoRow(
                    'Método',
                    _orcamento!.metodoPagamento!,
                    color: ModernColors.pagamentoText,
                  ),
                  if (_orcamento!.parcelas != null) ...[
                    const Divider(height: 16),
                    _buildInfoRow(
                      'Parcelamento',
                      '${_orcamento!.parcelas}x',
                      color: ModernColors.pagamentoText,
                    ),
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
        color: ModernColors.infoBackground,
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
                    color: ModernColors.infoIcon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: ModernColors.infoText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informações Adicionais',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.infoText,
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
                  color: ModernColors.infoText,
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
    Color backgroundColor;
    Color textColor;
    Color iconBgColor;

    switch (title) {
      case 'Laudo Técnico':
        icon = Icons.description;
        backgroundColor = ModernColors.laudoBackground;
        textColor = ModernColors.laudoText;
        iconBgColor = ModernColors.laudoIcon;
        break;
      case 'Garantia':
        icon = Icons.verified_user;
        backgroundColor = ModernColors.garantiaBackground;
        textColor = ModernColors.garantiaText;
        iconBgColor = ModernColors.garantiaIcon;
        break;
      case 'Condições Contratuais':
        icon = Icons.gavel;
        backgroundColor = ModernColors.contratoBackground;
        textColor = ModernColors.contratoText;
        iconBgColor = ModernColors.contratoIcon;
        break;
      default:
        icon = Icons.article;
        backgroundColor = ModernColors.infoBackground;
        textColor = ModernColors.infoText;
        iconBgColor = ModernColors.infoIcon;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                    color: iconBgColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: textColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                style: TextStyle(fontSize: 15, height: 1.6, color: textColor),
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
        color: ModernColors.fotosBackground,
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
                    color: ModernColors.fotosIcon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: ModernColors.fotosText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fotos do Orçamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.fotosText,
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

  Widget _buildBottomCard() {
    final valorTotal = Formatters.formatCurrency(_orcamento!.valorTotal);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Valor Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.valoresBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ModernColors.valoresText,
                        ),
                      ),
                      Text(
                        valorTotal,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ModernColors.valoresText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Botões
                Row(
                  children: [
                    // Botão Recusar
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implementar lógica de recusar orçamento
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Orçamento recusado'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text(
                          'Recusar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botão Aprovar
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar lógica de aprovar orçamento
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Orçamento aprovado!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text(
                          'Aprovar Orçamento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
}
