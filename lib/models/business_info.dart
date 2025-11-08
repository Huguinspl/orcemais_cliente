import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessInfo {
  final String nomeEmpresa;
  final String telefone;
  final String ramo;
  final String endereco;
  final String cnpj;
  final String emailEmpresa;
  final String? logoUrl;
  final String? pixTipo;
  final String? pixChave;
  final String? assinaturaUrl;
  final String? descricao;
  final Map<String, dynamic>? pdfTheme;

  const BusinessInfo({
    required this.nomeEmpresa,
    required this.telefone,
    required this.ramo,
    required this.endereco,
    required this.cnpj,
    required this.emailEmpresa,
    this.logoUrl,
    this.pixTipo,
    this.pixChave,
    this.assinaturaUrl,
    this.descricao,
    this.pdfTheme,
  });

  factory BusinessInfo.fromMap(Map<String, dynamic> map) => BusinessInfo(
    nomeEmpresa: map['nomeEmpresa'] ?? '',
    telefone: map['telefone'] ?? '',
    ramo: map['ramo'] ?? '',
    endereco: map['endereco'] ?? '',
    cnpj: map['cnpj'] ?? '',
    emailEmpresa: map['emailEmpresa'] ?? '',
    logoUrl: map['logoUrl'],
    pixTipo: map['pixTipo'],
    pixChave: map['pixChave'],
    assinaturaUrl: map['assinaturaUrl'],
    descricao: map['descricao'],
    pdfTheme: map['pdfTheme'] as Map<String, dynamic>?,
  );

  factory BusinessInfo.fromDoc(DocumentSnapshot doc) =>
      BusinessInfo.fromMap(doc.data() as Map<String, dynamic>);
}
