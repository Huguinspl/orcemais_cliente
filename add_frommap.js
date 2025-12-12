const fs = require('fs');

const content = fs.readFileSync('lib/models/recibo.dart', 'utf8');

// Adicionar fromMap logo após fromFirestore
const fromMapMethod = `

  factory Recibo.fromMap(Map<String, dynamic> data, {String? id}) {
    return Recibo(
      id: id ?? data['id'] ?? '',
      numero: data['numero'] ?? 0,
      cliente: Cliente.fromMap(data['cliente'] ?? {}),
      itens: List<Map<String, dynamic>>.from(data['itens'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      desconto: (data['desconto'] ?? 0.0).toDouble(),
      valorTotal: (data['valorTotal'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pago',
      dataCriacao: data['dataCriacao'] is Timestamp 
          ? data['dataCriacao'] 
          : Timestamp.now(),
      dataPagamento: data['dataPagamento'],
      metodoPagamento: data['metodoPagamento'],
      observacoes: data['observacoes'],
      informacoesAdicionais: data['informacoesAdicionais'],
      fotos: data['fotos'] != null ? List<String>.from(data['fotos']) : null,
    );
  }`;

// Inserir antes do último }
const lastBraceIdx = content.lastIndexOf('}');
const newContent = content.slice(0, lastBraceIdx) + fromMapMethod + '\n}\n';

fs.writeFileSync('lib/models/recibo.dart', newContent, 'utf8');
console.log('fromMap adicionado ao Recibo!');
