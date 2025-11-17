import 'package:flutter/material.dart';
import '../models/recibo.dart';
import '../models/business_info.dart';
import '../models/custom_theme.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/business_header.dart';
import '../widgets/recibo_card.dart';
import '../widgets/item_card.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

class VisualizarReciboPage extends StatefulWidget {
  final String? userId;
  final String? reciboId;
  final CustomTheme? customTheme;

  const VisualizarReciboPage({
    super.key,
    this.userId,
    this.reciboId,
    this.customTheme,
  });

  @override
  State<VisualizarReciboPage> createState() => _VisualizarReciboPageState();
}

class _VisualizarReciboPageState extends State<VisualizarReciboPage> {
  bool _isLoading = true;
  Recibo? _recibo;
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
      if (widget.userId == null || widget.reciboId == null) {
        throw Exception('Parâmetros inválidos');
      }

      print('📊 Carregando dados do recibo...');
      print('   userId: ${widget.userId}');
      print('   reciboId: ${widget.reciboId}');

      // Buscar dados em paralelo para melhor performance
      final results = await Future.wait([
        _firestoreService.getRecibo(widget.userId!, widget.reciboId!),
        _firestoreService.getBusinessInfo(widget.userId!),
      ]);

      final recibo = results[0] as Recibo?;
      final businessInfo = results[1] as BusinessInfo?;

      if (recibo == null) {
        throw Exception('Recibo não encontrado ou não está disponível');
      }

      if (businessInfo == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      setState(() {
        _recibo = recibo;
        _businessInfo = businessInfo;
        _isLoading = false;
      });

      print('✅ Dados do recibo carregados com sucesso!');
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
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Recibo'),
        backgroundColor: AppConstants.successColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando recibo...');
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_recibo == null || _businessInfo == null) {
      return const Center(child: Text('Recibo não encontrado'));
    }

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
                // Card do recibo
                ReciboCard(recibo: _recibo!),

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
                if (_recibo!.metodoPagamento != null) _buildPagamentoSection(),

                // Observações
                if (_recibo!.observacoes != null &&
                    _recibo!.observacoes!.isNotEmpty)
                  _buildObservacoesSection(),

                // Informações adicionais
                if (_recibo!.informacoesAdicionais != null &&
                    _recibo!.informacoesAdicionais!.isNotEmpty)
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
    final cliente = _recibo!.cliente;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recebido de',
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
          'Itens do Recibo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...(_recibo!.itens.map((item) => ItemCard(item: item))),
      ],
    );
  }

  Widget _buildResumoFinanceiro() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResumoRow(
              'Subtotal',
              Formatters.formatCurrency(_recibo!.subtotal),
            ),
            if (_recibo!.desconto > 0) ...[
              const SizedBox(height: 8),
              _buildResumoRow(
                'Desconto',
                '- ${Formatters.formatCurrency(_recibo!.desconto)}',
                color: AppConstants.successColor,
              ),
            ],
            const Divider(height: 20),
            _buildResumoRow(
              'VALOR PAGO',
              Formatters.formatCurrency(_recibo!.valorTotal),
              isBold: true,
              fontSize: 20,
              color: AppConstants.successColor,
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
              'Informações de Pagamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Método', _recibo!.metodoPagamento!),
            if (_recibo!.dataPagamento != null)
              _buildInfoRow(
                'Data do Pagamento',
                Formatters.formatDate(_recibo!.dataPagamento!.toDate()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacoesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(_recibo!.observacoes!, style: const TextStyle(fontSize: 14)),
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
              _recibo!.informacoesAdicionais!,
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
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'RECIBO PAGO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Emitido em ${Formatters.formatDate(_recibo!.dataCriacao.toDate())}',
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
