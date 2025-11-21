import 'package:flutter/material.dart';

enum LeadStatus {
  all,
  newLead,
  contacted,
  converted,
  lost,
}

extension LeadStatusExtension on LeadStatus {
  String get displayName {
    switch (this) {
      case LeadStatus.all: return 'All';
      case LeadStatus.newLead: return 'New';
      case LeadStatus.contacted: return 'Contacted';
      case LeadStatus.converted: return 'Converted';
      case LeadStatus.lost: return 'Lost';
    }
  }

  Color get color {
    switch (this) {
      case LeadStatus.all: return Colors.blueGrey;
      case LeadStatus.newLead: return const Color(0xFF007AFF);
      case LeadStatus.contacted: return Colors.orange.shade700;
      case LeadStatus.converted: return Colors.green;
      case LeadStatus.lost: return Colors.red.shade600;
    }
  }

  static LeadStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'new': return LeadStatus.newLead;
      case 'contacted': return LeadStatus.contacted;
      case 'converted': return LeadStatus.converted;
      case 'lost': return LeadStatus.lost;
      default: return LeadStatus.newLead; 
    }
  }
}