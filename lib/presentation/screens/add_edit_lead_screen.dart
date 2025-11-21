import 'package:flutter/material.dart';
import '/core/constant/app_colors.dart';
import '/core/constant/lead_status.dart';
import '/data/models/lead_model.dart';
import '/presentation/provider/lead_provider.dart';
import 'package:provider/provider.dart';

class AddEditLeadScreen extends StatefulWidget {
  final Lead? leadToEdit;

  const AddEditLeadScreen({super.key, this.leadToEdit});

  @override
  State<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends State<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;

  bool get isEditing => widget.leadToEdit != null;

  @override
  void initState() {
    super.initState();
    final lead = widget.leadToEdit;
    _nameController = TextEditingController(text: lead?.name ?? '');
    _phoneController = TextEditingController(text: lead?.phone ?? '');
    _emailController = TextEditingController(text: lead?.email ?? '');
    _notesController = TextEditingController(text: lead?.notes ?? '');

    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required.';
    }
    
    const pattern = r'^\+?[0-9\s\-\(\)]{8,15}$'; 
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number (8-15 digits, optional +).';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email Address is required.';
    }
    
   
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  

  void _saveLead() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      
      final Lead newOrUpdatedLead = Lead(
        id: widget.leadToEdit?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        status: widget.leadToEdit?.status ?? LeadStatus.newLead, 
        createdAt: widget.leadToEdit?.createdAt ?? now,
        lastUpdatedAt: now,
      );

      final provider = Provider.of<LeadProvider>(context, listen: false);

      if (isEditing) {
        await provider.updateLead(newOrUpdatedLead);
        Navigator.of(context).pop(newOrUpdatedLead); 
      } else {
        await provider.addLead(newOrUpdatedLead);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Lead' : 'Add Lead'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isEditing ? 'Update lead information below' : 'Fill in the details below to add a new lead to your pipeline',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              _buildLabel('Lead Name *', context),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter full name',
                icon: Icons.person_outline,
                validator: (val) => _validateRequired(val, 'Lead Name'),
              ),

              _buildLabel('Phone Number *', context),
              _buildTextField(
                controller: _phoneController,
                hint: 'Enter Phone number',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                
                validator: _validatePhoneNumber,
              ),

              _buildLabel('Email Address *', context),
              _buildTextField(
                controller: _emailController,
                hint: 'email@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                
                validator: _validateEmail,
              ),

              _buildLabel('Notes / Description', context),
              _buildTextField(
                controller: _notesController,
                hint: 'Add any additional notes about this lead...',
                icon: Icons.description_outlined,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: null, 
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveLead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    isEditing ? 'Update Lead' : 'Save Lead',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
        suffixIcon: controller.text.isNotEmpty && (validator == null || validator(controller.text) == null)
            ? const Icon(Icons.check_circle, color: Colors.green) 
            : null,
      ),
      validator: validator,
    );
  }
}