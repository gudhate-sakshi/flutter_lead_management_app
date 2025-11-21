import 'package:flutter/material.dart';
import '/core/constant/app_colors.dart';
import '/core/constant/lead_status.dart';
import '/core/utils/data_utils.dart';
import '/data/models/lead_model.dart';
import '/presentation/provider/lead_provider.dart';
import '/presentation/screens/add_edit_lead_screen.dart';
import '/presentation/widgets/lead_status_chip.dart';
import 'package:provider/provider.dart';

class LeadDetailsScreen extends StatefulWidget {
  final Lead lead;

  const LeadDetailsScreen({super.key, required this.lead});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  late Lead _currentLead;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
  }

  Future<void> _updateStatus(LeadStatus newStatus) async {
    if (_currentLead.status == newStatus || _isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    final provider = Provider.of<LeadProvider>(context, listen: false);
    final updatedLead = await provider.updateLeadStatus(_currentLead.id!, newStatus);

    if (updatedLead != null) {
      setState(() {
        _currentLead = updatedLead;
      });
    }

    setState(() {
      _isUpdatingStatus = false;
    });
  }

  Future<void> _navigateToEditScreen() async {
    final updatedLead = await Navigator.of(context).push<Lead>(
      MaterialPageRoute(
        builder: (context) => AddEditLeadScreen(leadToEdit: _currentLead),
      ),
    );

    if (updatedLead != null) {
      setState(() {
        _currentLead = updatedLead;
      });
    }
  }

  

  Future<void> _deleteLead() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to permanently delete ${_currentLead.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentLead.id != null) {
      final provider = Provider.of<LeadProvider>(context, listen: false);
            await provider.deleteLead(_currentLead.id!);
      
     
      Navigator.of(context).pop(); 
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Details'),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEditScreen,
          ),
          
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteLead,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(_currentLead.name, _currentLead.status.color),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentLead.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                    const SizedBox(height: 4),
                    LeadStatusChip(status: _currentLead.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoCard(context),
            const SizedBox(height: 24),

            Text('Update Status', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildStatusUpdateGrid(context),
            const SizedBox(height: 24),

            _buildTimestampRow(
              context,
              icon: Icons.access_time,
              label: 'Created',
              date: _currentLead.createdAt,
            ),
            const SizedBox(height: 12),
            _buildTimestampRow(
              context,
              icon: Icons.access_time,
              label: 'Last Updated',
              date: _currentLead.lastUpdatedAt,
              isLoading: _isUpdatingStatus,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color statusColor) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '';
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value, required Color iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(context, icon: Icons.call_outlined, label: 'Phone', value: _currentLead.phone, iconColor: AppColors.callIconColor),
            const Divider(height: 20, thickness: 0.5),
            _buildDetailRow(context, icon: Icons.mail_outline, label: 'Email', value: _currentLead.email, iconColor: AppColors.mailIconColor),
            if (_currentLead.notes != null && _currentLead.notes!.isNotEmpty) ...[
              const Divider(height: 20, thickness: 0.5),
              _buildDetailRow(context, icon: Icons.description_outlined, label: 'Notes', value: _currentLead.notes!, iconColor: AppColors.notesIconColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateGrid(BuildContext context) {
    final updateStatuses = LeadStatus.values.where((s) => s != LeadStatus.all).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: updateStatuses.length,
      itemBuilder: (context, index) {
        final status = updateStatuses[index];
        final isSelected = status == _currentLead.status;
        final color = status.color;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? color : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isUpdatingStatus || isSelected ? null : () => _updateStatus(status),
              child: Center(
                child: _isUpdatingStatus && isSelected 
                  ? const SizedBox(
                      width: 18, 
                      height: 18, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                    status.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimestampRow(BuildContext context, {required IconData icon, required String label, required DateTime date, bool isLoading = false}) {
    final formattedDate = AppDateUtils.formatMonthDayYear(date);
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ]
              ],
            ),
          ],
        ),
      ],
    );
  }
}