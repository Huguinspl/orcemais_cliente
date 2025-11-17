import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_info.dart';
import '../models/custom_theme.dart';
import '../utils/formatters.dart';

class BusinessHeader extends StatelessWidget {
  final BusinessInfo businessInfo;
  final CustomTheme? customTheme;

  const BusinessHeader({
    super.key,
    required this.businessInfo,
    this.customTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = customTheme ?? CustomTheme.defaultTheme;
    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (businessInfo.logoUrl != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: businessInfo.logoUrl!,
                height: 70,
                placeholder: (context, url) => const SizedBox(
                  height: 70,
                  width: 70,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.business, size: 70, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            businessInfo.nomeEmpresa,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            businessInfo.ramo,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
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
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
