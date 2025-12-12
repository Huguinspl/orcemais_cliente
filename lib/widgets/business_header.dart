import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_info.dart';
import '../models/custom_theme.dart';
import '../utils/formatters.dart';
import '../utils/modern_colors.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.75,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
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
                  color: ModernColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ModernColors.primary.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: businessInfo.logoUrl!,
                  height: 80,
                  placeholder: (context, url) => const SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.business,
                    size: 80,
                    color: ModernColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              businessInfo.nomeEmpresa,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ModernColors.primary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              businessInfo.ramo,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildWhatsAppButton(
                    businessInfo.telefone,
                    businessInfo.nomeEmpresa,
                  ),
                  _buildTextInfo(businessInfo.emailEmpresa),
                  if (businessInfo.endereco.isNotEmpty)
                    _buildInfoItem(Icons.location_on, businessInfo.endereco),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(String telefone, String nomeEmpresa) {
    // Remover formatação para criar o link do WhatsApp
    final telefoneLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
    final mensagem = Uri.encodeComponent(
      'Olá! Gostaria de mais informações sobre o orçamento.',
    );
    final whatsappUrl = 'https://wa.me/55$telefoneLimpo?text=$mensagem';

    return TextButton.icon(
      onPressed: () async {
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 18),
      label: Text(
        Formatters.formatPhone(telefone),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTextInfo(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: ModernColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

