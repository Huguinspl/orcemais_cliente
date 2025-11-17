# Integração para Criar Link Web do Orçamento

## Como enviar os parâmetros do orçamento ao criar o link

### 1. No arquivo `EtapaLinkWebPage` adicione o método para criar o link:

```dart
import 'package:deep_link/services/link_service.dart';

class _EtapaLinkWebPageState extends State<EtapaLinkWebPage> {
  bool _isCreatingLink = false;
  String? _linkGerado;

  // ... código existente ...

  Future<void> _criarLinkWeb() async {
    setState(() {
      _isCreatingLink = true;
    });

    try {
      // Obter userId (do Firebase Auth ou Provider)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // 1. Primeiro, salvar o orçamento no Firestore
      final orcamentoId = await _salvarOrcamentoNoFirestore(userId);

      // 2. Criar o Deep Link com TODOS os parâmetros
      final link = await DeepLink.createLink(
        parametrosPersonalizados: {
          // OBRIGATÓRIOS para buscar no Firestore
          'userId': userId,
          'documentoId': orcamentoId,
          'tipoDocumento': 'orcamento', // ou 'recibo'
        },
        dominioPersonalizado: 'https://gestorfy-cliente.web.app',
      );

      setState(() {
        _linkGerado = link.shortUrl;
        _isCreatingLink = false;
      });

      // 3. Mostrar o link para o usuário compartilhar
      _mostrarDialogoLink(link.shortUrl);

    } catch (e) {
      print('❌ Erro ao criar link: $e');
      setState(() {
        _isCreatingLink = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar link: $e')),
      );
    }
  }

  Future<String> _salvarOrcamentoNoFirestore(String userId) async {
    final db = FirebaseFirestore.instance;

    // Criar documento do orçamento
    final orcamentoRef = await db
        .collection('business')
        .doc(userId)
        .collection('orcamentos')
        .add({
      'numero': _gerarNumeroOrcamento(), // Implementar lógica de numeração
      'cliente': {
        'nome': widget.cliente.nome,
        'celular': widget.cliente.celular,
        'email': widget.cliente.email,
        'cpfCnpj': widget.cliente.cpfCnpj,
      },
      'itens': widget.itens.map((item) => {
        'nome': item['nome'],
        'descricao': item['descricao'] ?? '',
        'preco': item['preco'],
        'quantidade': item['quantidade'],
      }).toList(),
      'subtotal': widget.subtotal,
      'desconto': widget.desconto,
      'valorTotal': widget.valorTotal,
      'status': 'Enviado', // IMPORTANTE: deve estar "Enviado" para ser visível
      'dataCriacao': FieldValue.serverTimestamp(),
      // Campos opcionais:
      'metodoPagamento': null,
      'parcelas': null,
      'laudoTecnico': null,
      'condicoesContratuais': null,
      'garantia': null,
      'informacoesAdicionais': null,
      'fotos': [],
    });

    return orcamentoRef.id;
  }

  void _mostrarDialogoLink(String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Criado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Compartilhe este link com seu cliente:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copiado!')),
              );
            },
            child: const Text('COPIAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  int _gerarNumeroOrcamento() {
    // Implementar lógica para gerar número sequencial
    // Pode buscar o último número do Firestore e incrementar
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }
}
```

### 2. Adicionar botão na UI para criar o link:

```dart
// No build() da EtapaLinkWebPage, após os totais:

const SizedBox(height: 32),

// Botão para criar link
ElevatedButton.icon(
  onPressed: _isCreatingLink ? null : _criarLinkWeb,
  icon: _isCreatingLink
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Icon(Icons.link),
  label: Text(
    _isCreatingLink ? 'Criando link...' : 'Criar Link Web',
  ),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
  ),
),

if (_linkGerado != null) ...[
  const SizedBox(height: 16),
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.shade300),
    ),
    child: Column(
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Link criado com sucesso!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SelectableText(
          _linkGerado!,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  ),
],
```

### 3. Estrutura no Firestore (já configurada):

```
business/
  {userId}/
    orcamentos/
      {orcamentoId}/
        - numero: 1234
        - cliente: {nome, celular, email, cpfCnpj}
        - itens: [{nome, descricao, preco, quantidade}, ...]
        - subtotal: 1000.00
        - desconto: 50.00
        - valorTotal: 950.00
        - status: "Enviado"  ← DEVE ESTAR "Enviado" PARA SER VISÍVEL
        - dataCriacao: Timestamp
        - metodoPagamento: null
        - parcelas: null
        - informacoesAdicionais: null
        - fotos: []
```

### 4. Fluxo Completo:

1. **Usuário preenche orçamento** → `EtapaLinkWebPage`
2. **Clica em "Criar Link Web"** → Chama `_criarLinkWeb()`
3. **Salva no Firestore** → Collection `business/{userId}/orcamentos`
4. **Cria Deep Link** → Com `userId`, `documentoId`, `tipoDocumento`
5. **Retorna link curto** → Ex: `https://link.deeplinkhub.com/abc123`
6. **Cliente abre o link** → Redireciona para `https://gestorfy-cliente.web.app/?idLink=abc123`
7. **App busca no Firestore** → Usando `userId` e `documentoId` do Deep Link
8. **Exibe orçamento** → `VisualizarOrcamentoPage`

### 5. Parâmetros OBRIGATÓRIOS no Deep Link:

```dart
parametrosPersonalizados: {
  'userId': 'abc123xyz',           // UID do Firebase Auth
  'documentoId': 'orcamento456',   // ID do documento no Firestore
  'tipoDocumento': 'orcamento',    // 'orcamento' ou 'recibo'
}
```

### 6. Para criar link de RECIBO (mesma lógica):

```dart
// Salvar em: business/{userId}/recibos/{reciboId}
// Status deve ser: "Pago"
parametrosPersonalizados: {
  'userId': userId,
  'documentoId': reciboId,
  'tipoDocumento': 'recibo',  // ← Diferença aqui
}
```

## Observações Importantes:

1. ✅ O `gestorfy_cliente` já está pronto para receber esses parâmetros
2. ✅ Não precisa enviar todos os dados do orçamento no link (apenas IDs)
3. ✅ Os dados completos ficam no Firestore de forma segura
4. ✅ O link fica curto e fácil de compartilhar
5. ⚠️ Status "Enviado" é obrigatório para orçamentos serem visíveis
6. ⚠️ Status "Pago" é obrigatório para recibos serem visíveis
