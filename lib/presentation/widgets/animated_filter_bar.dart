import 'package:flutter/material.dart';
import '/core/constant/lead_status.dart';
import '/presentation/provider/lead_provider.dart';
import 'package:provider/provider.dart';

class AnimatedFilterBar extends StatelessWidget {
  const AnimatedFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);
    final selectedStatus = leadProvider.selectedStatus;
    final statuses = LeadStatus.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: statuses.map((status) {
          final isSelected = status == selectedStatus;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected ? status.color : Theme.of(context).cardColor,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: status.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    leadProvider.setSelectedStatus(status);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      status.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}