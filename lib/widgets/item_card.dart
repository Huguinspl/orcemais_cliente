import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../utils/modern_colors.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tipo = item['tipo'] ?? 'produto';
    final nome = item['nome'] ?? '';
    final descricao = item['descricao'] ?? '';
    final quantidade = (item['quantidade'] ?? 1).toDouble();
    final preco = (item['preco'] ?? 0.0).toDouble();
    final subtotal = quantidade * preco;
    final unidade = item['unidade'] ?? 'un';

    // Ícones por tipo
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (tipo.toLowerCase()) {
      case 'servico':
      case 'serviço':
        iconData = Icons.build_outlined;
        iconColor = const Color(0xFF3B82F6);
        backgroundColor = const Color(0xFF3B82F6).withOpacity(0.1);
        break;
      case 'peca':
      case 'peça':
      case 'material':
        iconData = Icons.inventory_2_outlined;
        iconColor = const Color(0xFF10B981);
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        break;
      case 'mao_de_obra':
      case 'mão de obra':
        iconData = Icons.engineering_outlined;
        iconColor = const Color(0xFFF59E0B);
        backgroundColor = const Color(0xFFF59E0B).withOpacity(0.1);
        break;
      default:
        iconData = Icons.shopping_bag_outlined;
        iconColor = ModernColors.primary;
        backgroundColor = ModernColors.primary.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com ícone e nome
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (tipo.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatarTipo(tipo),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Descrição (se existir)
            if (descricao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        descricao,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Informações de quantidade e preço
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.numbers,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Quantidade:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${quantidade.toStringAsFixed(quantidade.truncateToDouble() == quantidade ? 0 : 2)} $unidade',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Preço Unitário:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.formatCurrency(preco),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),

            // Subtotal destacado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.primary.withOpacity(0.08),
                    ModernColors.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ModernColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ModernColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.calculate,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.formatCurrency(subtotal),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ModernColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'servico':
      case 'serviço':
        return 'Serviço';
      case 'peca':
      case 'peça':
        return 'Peça';
      case 'material':
        return 'Material';
      case 'mao_de_obra':
      case 'mão de obra':
        return 'Mão de Obra';
      default:
        return tipo;
    }
  }
}
