import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppConstants.getTipoItemIcon(tipo),
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                descricao,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qtd: ${quantidade.toStringAsFixed(quantidade.truncateToDouble() == quantidade ? 0 : 2)} $unidade',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  Formatters.formatCurrency(preco),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.formatCurrency(subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
