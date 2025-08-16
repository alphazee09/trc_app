import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/user_model.dart';
import '../../core/services/bazari_api_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/token_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fingerprintEnabled = false;
  bool _fingerprintAvailable = false;
  bool _isLoading = false;
  String _biometricStatus = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load biometric settings
      _fingerprintAvailable = await BiometricService.isFingerprintAvailable();
      _fingerprintEnabled = await BiometricService.isFingerprintEnabled();
      _biometricStatus = await BiometricService.getBiometricStatusMessage();

      // Load user profile
      _currentUser = await BazariApiService.getUserProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFingerprint(bool value) async {
    if (!_fingerprintAvailable) {
      _showFingerprintNotAvailableDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      BiometricResult result;
      
      if (value) {
        result = await BiometricService.enableFingerprint();
      } else {
        result = await BiometricService.disableFingerprint();
      }

      if (result.success) {
        setState(() {
          _fingerprintEnabled = value;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value 
                ? 'Fingerprint authentication enabled' 
                : 'Fingerprint authentication disabled'
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update fingerprint setting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFingerprintNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Fingerprint Not Available',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          _biometricStatus,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await BazariApiService.logout();
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Section
              if (_currentUser != null) ...[
                _buildUserProfileCard(),
                const SizedBox(height: 20),
              ],

              // Security Settings
              _buildSectionTitle('Security'),
              _buildSecuritySettings(),
              const SizedBox(height: 20),

              // App Settings
              _buildSectionTitle('App Settings'),
              _buildAppSettings(),
              const SizedBox(height: 20),

              // Account Actions
              _buildSectionTitle('Account'),
              _buildAccountActions(),
              const SizedBox(height: 40),

              // Logout Button
              CustomButton(
                text: 'Logout',
                onPressed: _logout,
                backgroundColor: Colors.red,
                icon: Icons.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _currentUser!.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser!.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                if (_currentUser!.isVerified) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(
              Icons.edit,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Fingerprint Authentication',
            subtitle: _biometricStatus,
            trailing: Switch(
              value: _fingerprintEnabled,
              onChanged: _fingerprintAvailable ? _toggleFingerprint : null,
              activeColor: AppTheme.primaryColor,
            ),
            icon: Icons.fingerprint,
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Change Password',
            subtitle: 'Update your account password',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.lock,
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.notifications,
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Language',
            subtitle: 'English (US)',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.language,
            onTap: () {
              // TODO: Navigate to language settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Help & Support',
            subtitle: 'Get help with your account',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.help,
            onTap: () {
              // TODO: Navigate to help screen
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.description,
            onTap: () {
              // TODO: Navigate to terms screen
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            icon: Icons.privacy_tip,
            onTap: () {
              // TODO: Navigate to privacy screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.1),
      indent: 72,
      endIndent: 16,
    );
  }
}