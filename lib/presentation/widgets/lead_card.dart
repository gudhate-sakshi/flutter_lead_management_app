import 'package:flutter/material.dart';
import '/core/constant/app_colors.dart';
import '/data/models/lead_model.dart';
import '/presentation/screens/lead_detail_screen.dart';
import '/presentation/widgets/lead_status_chip.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final int index;

  const LeadCard({super.key, required this.lead, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LeadDetailsScreen(lead: lead),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        lead.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    LeadStatusChip(status: lead.status),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  icon: Icons.call_outlined,
                  iconColor: AppColors.callIconColor,
                  text: lead.phone,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  icon: Icons.mail_outline,
                  iconColor: AppColors.mailIconColor,
                  text: lead.email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required Color iconColor, required String text}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}