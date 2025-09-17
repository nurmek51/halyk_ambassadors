import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/application_entities.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final bool isLatest;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.isLatest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (application.address.city.isNotEmpty)
                            Text(
                              'г. ${application.address.city}',
                              style: const TextStyle(
                                fontFamily: 'Mabry Pro',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0x99000000),
                                height: 1.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.topRight,
                      child: _buildStatusChip(
                        isLatest ? 'Новая' : application.status,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  application.addressDisplay,
                  style: const TextStyle(
                    fontFamily: 'Mabry Pro',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0x99000000),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  application.description,
                  style: const TextStyle(
                    fontFamily: 'Mabry Pro',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDate(application.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Mabry Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99000000),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    // Handle special case for latest application
    if (status == 'Новая') {
      backgroundColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFF856404);
      displayText = 'Новая';
    } else {
      switch (status.toLowerCase()) {
        case 'pending':
          backgroundColor = const Color(0xFFD1ECF1);
          textColor = const Color(0xFF0C5460);
          displayText = 'В работе';
          break;
        case 'approved':
        case 'completed':
          backgroundColor = const Color(0xFFD4EDDA);
          textColor = const Color(0xFF155724);
          displayText = 'Готово';
          break;
        case 'rejected':
          backgroundColor = const Color(0xFFF8D7DA);
          textColor = const Color(0xFF721C24);
          displayText = 'Отклонена';
          break;
        case 'in_progress':
          backgroundColor = const Color(0xFFD1ECF1);
          textColor = const Color(0xFF0C5460);
          displayText = 'В работе';
          break;
        default:
          backgroundColor = const Color(0xFFE2E3F1);
          textColor = const Color(0xFF383D3B);
          displayText = status;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontFamily: 'Mabry Pro',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.3,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(date);
  }
}
