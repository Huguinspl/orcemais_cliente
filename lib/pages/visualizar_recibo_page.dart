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
        title: const Text(
          'Recibo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 80,
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
          BusinessHeader(
            businessInfo: _businessInfo!,
            customTheme: widget.customTheme,
          ),

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

                // Fotos do Recibo
                if (_recibo!.fotos != null && _recibo!.fotos!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildFotosSection(),
                ],

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
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;
    final tertiaryContainer = theme.tertiaryContainerColor;

    final cliente = _recibo!.cliente;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tertiaryContainer, tertiaryContainer.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
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
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'RECEBIDO DE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.85)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'ITENS DO RECIBO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...(_recibo!.itens.map((item) => ItemCard(item: item))),
      ],
    );
  }

  Widget _buildResumoFinanceiro() {
    // Calcular custos adicionais dos itens
    double custosAdicionais = 0.0;
    for (var item in _recibo!.itens) {
      final custo = (item['custo'] as num?)?.toDouble() ?? 0.0;
      custosAdicionais += custo;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 16)),
              Text(
                Formatters.formatCurrency(_recibo!.subtotal),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          // Custos Adicionais
          if (custosAdicionais > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Custos Adicionais', style: TextStyle(fontSize: 16)),
                Text(
                  Formatters.formatCurrency(custosAdicionais),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],

          // Desconto
          if (_recibo!.desconto > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Desconto', style: TextStyle(fontSize: 16)),
                Text(
                  '- ${Formatters.formatCurrency(_recibo!.desconto)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.successColor,
                  ),
                ),
              ],
            ),
          ],

          // Divisor
          const SizedBox(height: 16),
          Divider(color: Colors.grey[400], thickness: 1),
          const SizedBox(height: 16),

          // Valor Total - GARANTIDO VISÍVEL
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VALOR PAGO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(_recibo!.valorTotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Informações Adicionais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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

  Widget _buildFotosSection() {
    final theme = widget.customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Fotos do Recibo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: _recibo!.fotos!.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _recibo!.fotos![index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
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
}
