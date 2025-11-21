import 'package:flutter/material.dart';
import '/presentation/provider/lead_provider.dart';
import '/presentation/provider/theme_provider.dart';
import '/presentation/screens/add_edit_lead_screen.dart';
import '/presentation/widgets/animated_filter_bar.dart';
import '/presentation/widgets/staggered_lead_card.dart';
import 'package:provider/provider.dart';
import '/core/constant/lead_status.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert'; // Import for JSON formatting
// ADDED: Import the Lead model based on your AddEditLeadScreen file structure
import '/data/models/lead_model.dart'; // <<< ASSUMED PATH for Lead model
// ADDED: Import the new Tappable Animated Card widget
import '/presentation/widgets/tappable_animated_card.dart'; // <<< ASSUMED PATH

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late TextEditingController _searchController;
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _searchController = TextEditingController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadProvider>(context, listen: false).loadLeads();
    });
  }

  void _scrollListener() {
    final leadProvider = Provider.of<LeadProvider>(context, listen: false); 
    
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
      
      if (leadProvider.hasMoreLeads) {
        leadProvider.loadMoreLeads();
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose(); 
    super.dispose();
  }

  // RENAMED: This function now just handles the file creation and sharing
  Future<void> _sendJsonFile(BuildContext context, String jsonString) async {
    // 1. Get the temporary directory path
    final directory = await getTemporaryDirectory();
    // 2. Create a temporary file path for the JSON
    final file = File('${directory.path}/exported_leads.json');

    try {
      // 3. Write the JSON string to the file
      await file.writeAsString(jsonString);

      // 4. Launch the native share dialog with the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Lead Manager Export - Filtered Leads', // Optional message
        subject: 'Exported Lead Data', // Optional subject for emails
      );

    } catch (e) {
      // Show an error if file writing or sharing failed
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share file: $e')),
        );
      }
    }
  }

  // NEW FUNCTION: Shows the dialog with JSON preview and Send/Close buttons
  void _showExportDialog(BuildContext context, LeadProvider provider) {
    // Get the JSON string from the provider
    final String jsonString = provider.exportFilteredLeadsAsJson();
    
    // Format JSON for better readability in the dialog (optional but good practice)
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String formattedJson = encoder.convert(json.decode(jsonString));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Review Export Data'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Text(
                  formattedJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog first
                Navigator.of(dialogContext).pop(); 
                // Then call the send function with the JSON string
                _sendJsonFile(context, jsonString);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  
  void _toggleSearch(LeadProvider provider) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        provider.setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final leadProvider = Provider.of<LeadProvider>(context);

    final filteredLeads = leadProvider.filteredLeads;
    
    final int itemCount = filteredLeads.length + (filteredLeads.isEmpty ? 0 : 1);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSearching ? 'Search Leads' : 'Lead Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            // Existing logic: Call the new dialog function
            onPressed: () => _showExportDialog(context, leadProvider), 
            tooltip: 'Export Leads',
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.dark_mode_outlined),
            onPressed: themeProvider.toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
        bottom: _isSearching 
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) => leadProvider.setSearchQuery(query),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search leads...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            )
          : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AnimatedFilterBar(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${leadProvider.filteredLeadsTotal.length} leads found', 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: leadProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : leadProvider.filteredLeadsTotal.isEmpty
                    ? Center(
                        child: Text(
                          leadProvider.searchQuery.isNotEmpty 
                            ? 'No leads found for "${leadProvider.searchQuery}"'
                            : 'No ${leadProvider.selectedStatus.displayName} leads found.', 
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                          controller: _scrollController, 
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                              if (index == filteredLeads.length) {
                                  if (leadProvider.hasMoreLeads) {
                                      
                                      return const Center(
                                          child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(),
                                          ),
                                      );
                                  } else {
                                      
                                      return Padding(
                                          padding: const EdgeInsets.only(top: 20, bottom: 40),
                                          child: Center(
                                              child: Text(
                                                  '--- END OF LIST REACHED ---',
                                                  style: TextStyle(
                                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1.2,
                                                  ),
                                              ),
                                          ),
                                      );
                                  }
                              }
                              
                              // ADDED: Wrap the StaggeredLeadCard with TappableAnimatedCard
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8.8,10,8.8,10),
                                child: TappableAnimatedCard(
                                    baseColor: Theme.of(context).cardColor, 
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddEditLeadScreen(
                                            // FIX: Use the correct parameter name from AddEditLeadScreen
                                            leadToEdit: filteredLeads[index], 
                                          ),
                                        ),
                                      ).then((_) {
                                        // Reload data on return
                                        Provider.of<LeadProvider>(context, listen: false).loadLeads();
                                      });
                                    },
                                    child: StaggeredLeadCard(lead: filteredLeads[index], index: index),
                                ),
                              );
                          },
                        ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.easeOutBack,
        )),
        child: FloatingActionButton(
          onPressed: () {
            _fabAnimationController.forward().then((_) => _fabAnimationController.reverse());
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddEditLeadScreen(),
              ),
            ).then((_) {
              leadProvider.loadLeads();
            });
          },
          tooltip: 'Add New Lead',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}