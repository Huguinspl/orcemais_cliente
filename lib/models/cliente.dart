class Cliente {
  final String id;
  final String nome;
  final String celular;
  final String telefone;
  final String email;
  final String cpfCnpj;
  final String observacoes;

  Cliente({
    this.id = '',
    required this.nome,
    this.celular = '',
    this.telefone = '',
    this.email = '',
    this.cpfCnpj = '',
    this.observacoes = '',
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      celular: map['celular'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      cpfCnpj: map['cpfCnpj'] ?? '',
      observacoes: map['observacoes'] ?? '',
    );
  }
}
