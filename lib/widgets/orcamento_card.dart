import 'package:flutter/material.dart';
import '../models/orcamento.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

class OrcamentoCard extends StatelessWidget {
  final Orcamento orcamento;

  const OrcamentoCard({super.key, required this.orcamento});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orçamento #${orcamento.numero.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.getStatusColor(orcamento.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    orcamento.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${Formatters.formatDate(orcamento.dataCriacao.toDate())}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
