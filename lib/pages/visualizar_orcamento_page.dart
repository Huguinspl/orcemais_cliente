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
    // Usar tema personalizado ou padrão
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Orçamento'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
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
          BusinessHeader(businessInfo: _businessInfo!),

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

                // Informações adicionais
                if (_orcamento!.informacoesAdicionais != null &&
                    _orcamento!.informacoesAdicionais!.isNotEmpty)
                  _buildInfoAdicionaisSection(),

                const SizedBox(height: 32),

                // Rodapé
                _buildFooter(),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Nome', cliente.nome),
            if (cliente.celular.isNotEmpty)
              _buildInfoRow('Celular', Formatters.formatPhone(cliente.celular)),
            if (cliente.email.isNotEmpty) _buildInfoRow('Email', cliente.email),
            if (cliente.cpfCnpj.isNotEmpty)
              _buildInfoRow(
                'CPF/CNPJ',
                Formatters.formatCpfCnpj(cliente.cpfCnpj),
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
        const Text(
          'Itens do Orçamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...(_orcamento!.itens.map((item) => ItemCard(item: item))),
      ],
    );
  }

  Widget _buildResumoFinanceiro() {
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;
    final secondaryContainer = theme.secondaryContainerColor;

    return Card(
      color: secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResumoRow(
              'Subtotal',
              Formatters.formatCurrency(_orcamento!.subtotal),
            ),
            if (_orcamento!.desconto > 0) ...[
              const SizedBox(height: 8),
              _buildResumoRow(
                'Desconto',
                '- ${Formatters.formatCurrency(_orcamento!.desconto)}',
                color: AppConstants.successColor,
              ),
            ],
            const Divider(height: 20),
            _buildResumoRow(
              'VALOR TOTAL',
              Formatters.formatCurrency(_orcamento!.valorTotal),
              isBold: true,
              fontSize: 20,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagamentoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forma de Pagamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Método', _orcamento!.metodoPagamento!),
            if (_orcamento!.parcelas != null)
              _buildInfoRow('Parcelamento', '${_orcamento!.parcelas}x'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAdicionaisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Adicionais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              _orcamento!.informacoesAdicionais!,
              style: const TextStyle(fontSize: 14),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
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
