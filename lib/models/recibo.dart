import 'package:cloud_firestore/cloud_firestore.dart';
import 'cliente.dart';

class Recibo {
  final String id;
  final int numero;
  final Cliente cliente;
  final List<Map<String, dynamic>> itens;
  final double subtotal;
  final double desconto;
  final double valorTotal;
  final String status;
  final Timestamp dataCriacao;
  final Timestamp? dataPagamento;
  final String? metodoPagamento;
  final String? observacoes;
  final String? informacoesAdicionais;
  final List<String>? fotos;

  Recibo({
    required this.id,
    this.numero = 0,
    required this.cliente,
    required this.itens,
    required this.subtotal,
    required this.desconto,
    required this.valorTotal,
    required this.status,
    required this.dataCriacao,
    this.dataPagamento,
    this.metodoPagamento,
    this.observacoes,
    this.informacoesAdicionais,
    this.fotos,
  });

  factory Recibo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recibo(
      id: doc.id,
      numero: data['numero'] ?? 0,
      cliente: Cliente.fromMap(data['cliente'] ?? {}),
      itens: List<Map<String, dynamic>>.from(data['itens'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      desconto: (data['desconto'] ?? 0.0).toDouble(),
      valorTotal: (data['valorTotal'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pago',
      dataCriacao: data['dataCriacao'] ?? Timestamp.now(),
      dataPagamento: data['dataPagamento'],
      metodoPagamento: data['metodoPagamento'],
      observacoes: data['observacoes'],
      informacoesAdicionais: data['informacoesAdicionais'],
      fotos: data['fotos'] != null ? List<String>.from(data['fotos']) : null,
    );
  }


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
  }
}
