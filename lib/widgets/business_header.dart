import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_info.dart';
import '../utils/formatters.dart';

class BusinessHeader extends StatelessWidget {
  final BusinessInfo businessInfo;

  const BusinessHeader({super.key, required this.businessInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (businessInfo.logoUrl != null) ...[
            CachedNetworkImage(
              imageUrl: businessInfo.logoUrl!,
              height: 80,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.business, size: 80),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            businessInfo.nomeEmpresa,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            businessInfo.ramo,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoItem(
                Icons.phone,
                Formatters.formatPhone(businessInfo.telefone),
              ),
              _buildInfoItem(Icons.email, businessInfo.emailEmpresa),
              if (businessInfo.endereco.isNotEmpty)
                _buildInfoItem(Icons.location_on, businessInfo.endereco),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
