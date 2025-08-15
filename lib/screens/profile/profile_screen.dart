import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to edit profile
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: user?.profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user!.profileImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          user.initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 36,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    user?.initials ?? 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User Info
                        Text(
                          user?.fullName ?? 'User',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user?.username ?? 'username'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Verification Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: user?.isVerified == true 
                                ? AppTheme.successColor.withOpacity(0.2)
                                : AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user?.isVerified == true 
                                    ? Icons.verified 
                                    : Icons.warning,
                                size: 16,
                                color: user?.isVerified == true 
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user?.isVerified == true ? 'Verified' : 'Unverified',
                                style: TextStyle(
                                  color: user?.isVerified == true 
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Options
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Update your personal details',
                    onTap: () {
                      // TODO: Navigate to personal info
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Security Settings',
                    subtitle: 'Manage your security preferences',
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.verified_user,
                    title: 'KYC Verification',
                    subtitle: user?.isVerified == true 
                        ? 'Your account is verified'
                        : 'Complete your verification',
                    onTap: () {
                      Navigator.of(context).pushNamed('/kyc');
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.fingerprint,
                    title: 'Biometric Authentication',
                    subtitle: user?.fingerprintEnabled == true 
                        ? 'Enabled' 
                        : 'Disabled',
                    trailing: Switch(
                      value: user?.fingerprintEnabled ?? false,
                      onChanged: (value) async {
                        if (value) {
                          await authProvider.enableBiometric();
                        } else {
                          await authProvider.disableBiometric();
                        }
                      },
                    ),
                    onTap: null,
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_outline,
                    title: 'Notifications',
                    subtitle: 'Manage your notification preferences',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

