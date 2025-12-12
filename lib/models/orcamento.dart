import 'package:cloud_firestore/cloud_firestore.dart';
import 'cliente.dart';

class Orcamento {
  final String id;
  final int numero;
  final Cliente cliente;
  final List<Map<String, dynamic>> itens;
  final double subtotal;
  final double desconto;
  final double valorTotal;
  final String status;
  final Timestamp dataCriacao;
  final String? metodoPagamento;
  final int? parcelas;
  final String? laudoTecnico;
  final String? condicoesContratuais;
  final String? garantia;
  final String? informacoesAdicionais;
  final List<String>? fotos;
  final String? linkWeb; // Link web gerado para compartilhamento

  Orcamento({
    required this.id,
    this.numero = 0,
    required this.cliente,
    required this.itens,
    required this.subtotal,
    required this.desconto,
    required this.valorTotal,
    required this.status,
    required this.dataCriacao,
    this.metodoPagamento,
    this.parcelas,
    this.laudoTecnico,
    this.condicoesContratuais,
    this.garantia,
    this.informacoesAdicionais,
    this.fotos,
    this.linkWeb,
  });

  factory Orcamento.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Orcamento.fromMap(doc.id, data);
  }

  //  NOVO: Factory para criar a partir de um Map (usado pelo snapshot)
  factory Orcamento.fromMap(String id, Map<String, dynamic> data) {
    return Orcamento(
      id: data['id'] ?? id,
      numero: data['numero'] ?? 0,
      cliente: Cliente.fromMap(data['cliente'] ?? {}),
      itens: List<Map<String, dynamic>>.from(data['itens'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      desconto: (data['desconto'] ?? 0.0).toDouble(),
      valorTotal: (data['valorTotal'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Aberto',
      dataCriacao: data['dataCriacao'] ?? Timestamp.now(),
      metodoPagamento: data['metodoPagamento'],
      parcelas: data['parcelas'],
      laudoTecnico: data['laudoTecnico'],
      garantia: data['garantia'],
      informacoesAdicionais: data['informacoesAdicionais'],
      fotos: data['fotos'] != null ? List<String>.from(data['fotos']) : null,
      linkWeb: data['linkWeb'],
    );
  }

  Orcamento copyWith({
    String? id,
    int? numero,
    Cliente? cliente,
    List<Map<String, dynamic>>? itens,
    double? subtotal,
    double? desconto,
    double? valorTotal,
    String? status,
    Timestamp? dataCriacao,
    String? metodoPagamento,
    int? parcelas,
    String? laudoTecnico,
    String? condicoesContratuais,
    String? garantia,
    String? informacoesAdicionais,
    List<String>? fotos,
    String? linkWeb,
  }) {
    return Orcamento(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      cliente: cliente ?? this.cliente,
      itens: itens ?? this.itens,
      subtotal: subtotal ?? this.subtotal,
      desconto: desconto ?? this.desconto,
      valorTotal: valorTotal ?? this.valorTotal,
      status: status ?? this.status,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      metodoPagamento: metodoPagamento ?? this.metodoPagamento,
      parcelas: parcelas ?? this.parcelas,
      laudoTecnico: laudoTecnico ?? this.laudoTecnico,
      condicoesContratuais: condicoesContratuais ?? this.condicoesContratuais,
      garantia: garantia ?? this.garantia,
      informacoesAdicionais:
          informacoesAdicionais ?? this.informacoesAdicionais,
      fotos: fotos ?? this.fotos,
      linkWeb: linkWeb ?? this.linkWeb,
    );
  }
}
