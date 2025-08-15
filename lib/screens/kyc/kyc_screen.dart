import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  
  String _selectedDocumentType = 'passport';
  File? _documentFrontImage;
  File? _documentBackImage;
  File? _selfieImage;
  bool _isLoading = false;
  String? _kycStatus;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkKYCStatus();
  }

  Future<void> _checkKYCStatus() async {
    try {
      final response = await ApiService.getKYCStatus();
      if (response.success && response.data != 'not_submitted') {
        setState(() {
          _kycStatus = response.data['status'];
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          switch (type) {
            case 'front':
              _documentFrontImage = File(image.path);
              break;
            case 'back':
              _documentBackImage = File(image.path);
              break;
            case 'selfie':
              _selfieImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_documentFrontImage == null || _selfieImage == null) {
      _showErrorSnackBar('Please upload all required documents');
      return;
    }
    
    if (_selectedDocumentType != 'passport' && _documentBackImage == null) {
      _showErrorSnackBar('Please upload the back of your document');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final documentFront = await _fileToBase64(_documentFrontImage!);
      final selfie = await _fileToBase64(_selfieImage!);
      String? documentBack;
      
      if (_documentBackImage != null) {
        documentBack = await _fileToBase64(_documentBackImage!);
      }

      final response = await ApiService.submitKYC(
        documentType: _selectedDocumentType,
        documentNumber: _documentNumberController.text.trim(),
        documentFront: documentFront,
        documentBack: documentBack,
        selfieImage: selfie,
      );

      if (response.success) {
        _showSuccessSnackBar('KYC documents submitted successfully');
        setState(() {
          _kycStatus = 'pending';
        });
        
        // Refresh user profile
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshProfile();
      } else {
        _showErrorSnackBar(response.error ?? 'KYC submission failed');
      }
    } catch (e) {
      _showErrorSnackBar('KYC submission failed: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _kycStatus != null ? _buildKYCStatus() : _buildKYCForm(),
      ),
    );
  }

  Widget _buildKYCStatus() {
    IconData statusIcon;
    Color statusColor;
    String statusText;
    String statusDescription;

    switch (_kycStatus) {
      case 'pending':
        statusIcon = Icons.hourglass_empty;
        statusColor = AppTheme.warningColor;
        statusText = 'Under Review';
        statusDescription = 'Your KYC documents are being reviewed. This process usually takes 1-3 business days.';
        break;
      case 'approved':
        statusIcon = Icons.check_circle;
        statusColor = AppTheme.successColor;
        statusText = 'Verified';
        statusDescription = 'Your account has been successfully verified. You can now access all features.';
        break;
      case 'rejected':
        statusIcon = Icons.cancel;
        statusColor = AppTheme.errorColor;
        statusText = 'Rejected';
        statusDescription = 'Your KYC verification was rejected. Please contact support for more information.';
        break;
      default:
        return _buildKYCForm();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                statusIcon,
                size: 60,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              statusText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              statusDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            if (_kycStatus == 'rejected') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _kycStatus = null;
                  });
                },
                child: const Text('Resubmit Documents'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKYCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identity Verification',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Complete your KYC to unlock all features',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Document Type Selection
            Text(
              'Document Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedDocumentType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'passport', child: Text('Passport')),
                  DropdownMenuItem(value: 'driver_license', child: Text('Driver\'s License')),
                  DropdownMenuItem(value: 'national_id', child: Text('National ID')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDocumentType = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            
            // Document Number
            Text(
              'Document Number',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentNumberController,
              decoration: InputDecoration(
                hintText: 'Enter your document number',
                filled: true,
                fillColor: AppTheme.surfaceColor.withOpacity(0.5),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your document number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Document Images
            Text(
              'Document Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Front Image
            _buildImageUpload(
              title: 'Front of Document',
              image: _documentFrontImage,
              onTap: () => _pickImage('front'),
            ),
            const SizedBox(height: 16),
            
            // Back Image (if not passport)
            if (_selectedDocumentType != 'passport')
              Column(
                children: [
                  _buildImageUpload(
                    title: 'Back of Document',
                    image: _documentBackImage,
                    onTap: () => _pickImage('back'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // Selfie Image
            _buildImageUpload(
              title: 'Selfie with Document',
              image: _selfieImage,
              onTap: () => _pickImage('selfie'),
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitKYC,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit for Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your documents will be securely processed and stored. The verification process typically takes 1-3 business days.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take Photo',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

