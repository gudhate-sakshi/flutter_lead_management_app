import 'package:flutter/material.dart';
import '/core/constant/lead_status.dart';
import '/data/database/database_helper.dart';
import '/data/models/lead_model.dart';
import 'dart:convert';

class LeadProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Lead> _leads = [];
  LeadStatus _selectedStatus = LeadStatus.all;
  String _searchQuery = '';
  bool _isLoading = false;

  static const int _pageSize = 10;
  int _loadedCount = _pageSize;

  
  bool get hasMoreLeads => _loadedCount < filteredLeadsTotal.length;

  LeadStatus get selectedStatus => _selectedStatus;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Lead> get filteredLeadsTotal {
    return _leads.where((lead) {
      final statusMatch = _selectedStatus == LeadStatus.all ||
          lead.status == _selectedStatus;
      
      final searchMatch = _searchQuery.isEmpty ||
          lead.name.toLowerCase().contains(_searchQuery.toLowerCase()); 

      return statusMatch && searchMatch;
    }).toList();
  }

  List<Lead> get filteredLeads {
    final results = filteredLeadsTotal;
    return results.take(_loadedCount).toList();
  }

  String exportFilteredLeadsAsJson() {
    final List<Lead> leadsToExport = filteredLeadsTotal; 
    final List<Map<String, dynamic>> jsonList = 
        leadsToExport.map((lead) => lead.toJson()).toList();
    const encoder = JsonEncoder.withIndent('   ');
    return encoder.convert(jsonList);
  }

  Future<void> loadLeads() async {
    _isLoading = true;
    notifyListeners();
    try {
      _leads = await _dbHelper.getLeads();
      _loadedCount = _pageSize;
    } catch (e) {
      debugPrint("Error loading leads: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLead(Lead lead) async {
    final id = await _dbHelper.insertLead(lead);
    final newLead = lead.copyWith(id: id);
    _leads.add(newLead);
    _leads.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    notifyListeners();
  }

  Future<void> updateLead(Lead lead) async {
    await _dbHelper.updateLead(lead);
    final index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _leads[index] = lead;
      _leads.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
      notifyListeners();
    }
  }

  Future<void> deleteLead(int leadId) async {
    await _dbHelper.deleteLead(leadId);
    _leads.removeWhere((l) => l.id == leadId);
    notifyListeners();
  }

  Future<Lead?> updateLeadStatus(int leadId, LeadStatus newStatus) async {
    final Lead leadToUpdate = _leads.firstWhere((l) => l.id == leadId);
    
    if (leadToUpdate == null || leadToUpdate.status == newStatus) return leadToUpdate;

    final updatedLead = leadToUpdate.copyWith(
      status: newStatus,
      lastUpdatedAt: DateTime.now(),
    );

    await updateLead(updatedLead);
    return updatedLead;
  }

  void loadMoreLeads() {
    
    if (_loadedCount < filteredLeadsTotal.length) {
      
      int newLoadedCount = _loadedCount + _pageSize;

      if (newLoadedCount > filteredLeadsTotal.length) {
        _loadedCount = filteredLeadsTotal.length;
      } else {
        _loadedCount = newLoadedCount;
      }
      
      
      notifyListeners();
    }
  }

  void setSelectedStatus(LeadStatus status) {
    _selectedStatus = status;
    _loadedCount = _pageSize;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadedCount = _pageSize;
    notifyListeners();
  }
}