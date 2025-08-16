import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import 'token_manager.dart';
import 'bazari_api_service.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  static Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> isFingerprintAvailable() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFaceIDAvailable() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.contains(BiometricType.face);
    } catch (e) {
      return false;
    }
  }
  
  static Future<BiometricResult> authenticate({
    String localizedReason = 'Please authenticate to access your wallet',
    bool biometricOnly = false,
  }) async {
    try {
      final bool isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        return BiometricResult.error('Biometric authentication is not available');
      }
      
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
      
      if (didAuthenticate) {
        return BiometricResult.success();
      } else {
        return BiometricResult.error('Authentication failed');
      }
    } on PlatformException catch (e) {
      return BiometricResult.error(_handlePlatformException(e));
    } catch (e) {
      return BiometricResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Authenticate for app login
  static Future<BiometricResult> authenticateForLogin() async {
    return await authenticate(
      localizedReason: 'Use your fingerprint to sign in to Bazari Wallet',
      biometricOnly: true,
    );
  }

  /// Authenticate for transaction
  static Future<BiometricResult> authenticateForTransaction({
    required String currency,
    required double amount,
  }) async {
    return await authenticate(
      localizedReason: 'Confirm transaction: Send $amount $currency',
      biometricOnly: true,
    );
  }

  /// Authenticate for wallet access
  static Future<BiometricResult> authenticateForWallet() async {
    return await authenticate(
      localizedReason: 'Access your wallet with your fingerprint',
      biometricOnly: true,
    );
  }

  /// Enable fingerprint authentication
  static Future<BiometricResult> enableFingerprint() async {
    try {
      // Check if biometric is available
      final bool isAvailable = await isAvailable();
      if (!isAvailable) {
        return BiometricResult.error('Biometric authentication is not available on this device');
      }

      // Check if fingerprint is specifically available
      final bool fingerprintAvailable = await isFingerprintAvailable();
      if (!fingerprintAvailable) {
        return BiometricResult.error('Fingerprint authentication is not available on this device');
      }

      // Test authentication first
      final authResult = await authenticate(
        localizedReason: 'Enable fingerprint authentication for Bazari Wallet',
        biometricOnly: true,
      );

      if (!authResult.success) {
        return authResult;
      }

      // Update on server
      try {
        await BazariApiService.updateUserProfile(fingerprintEnabled: true);
      } catch (e) {
        // If API call fails, still enable locally
        print('Failed to update fingerprint setting on server: $e');
      }

      // Store locally
      await TokenManager.setFingerprintEnabled(true);

      return BiometricResult.success();
    } catch (e) {
      return BiometricResult.error('Failed to enable fingerprint: ${e.toString()}');
    }
  }

  /// Disable fingerprint authentication
  static Future<BiometricResult> disableFingerprint() async {
    try {
      // Update on server
      try {
        await BazariApiService.updateUserProfile(fingerprintEnabled: false);
      } catch (e) {
        // If API call fails, still disable locally
        print('Failed to update fingerprint setting on server: $e');
      }

      // Remove from local storage
      await TokenManager.setFingerprintEnabled(false);

      return BiometricResult.success();
    } catch (e) {
      return BiometricResult.error('Failed to disable fingerprint: ${e.toString()}');
    }
  }

  /// Check if fingerprint is enabled for the user
  static Future<bool> isFingerprintEnabled() async {
    try {
      return await TokenManager.isFingerprintEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Check if user can use fingerprint (available + enabled)
  static Future<bool> canUseFingerprint() async {
    final bool isAvailable = await isFingerprintAvailable();
    final bool isEnabled = await isFingerprintEnabled();
    return isAvailable && isEnabled;
  }
  
  static Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }
  
  static String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device';
      case 'NotEnrolled':
        return 'No biometric credentials are enrolled on this device. Please set up fingerprint or face recognition in your device settings.';
      case 'LockedOut':
        return 'Biometric authentication is temporarily locked out. Please try again later.';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is permanently locked out. Please use your device passcode.';
      case 'UserCancel':
        return 'Authentication was cancelled';
      case 'UserFallback':
        return 'User chose to use fallback authentication';
      case 'SystemCancel':
        return 'System cancelled biometric authentication';
      case 'InvalidContext':
        return 'Invalid authentication context';
      case 'NotSupported':
        return 'Biometric authentication is not supported on this device';
      case 'OtherOperatingSystem':
        return 'Biometric authentication is not supported on this operating system';
      case 'PasscodeNotSet':
        return 'Device passcode is not set. Please set up a passcode in your device settings.';
      case 'BiometryNotEnrolled':
        return 'No biometric credentials are enrolled. Please set up fingerprint or face recognition in your device settings.';
      default:
        return 'Biometric authentication error: ${e.message ?? 'Unknown error'}';
    }
  }
  
  static String getBiometricTypeString(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }
  
  static Future<String> getPrimaryBiometricType() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return 'None';
    
    // Prioritize fingerprint, then face recognition
    if (biometrics.contains(BiometricType.fingerprint)) {
      return getBiometricTypeString(BiometricType.fingerprint);
    } else if (biometrics.contains(BiometricType.face)) {
      return getBiometricTypeString(BiometricType.face);
    } else {
      return getBiometricTypeString(biometrics.first);
    }
  }

  /// Get a user-friendly message about biometric availability
  static Future<String> getBiometricStatusMessage() async {
    final bool isAvailable = await isAvailable();
    if (!isAvailable) {
      return 'Biometric authentication is not available on this device';
    }

    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return 'No biometric authentication methods are set up on this device';
    }

    final primaryType = await getPrimaryBiometricType();
    final isEnabled = await isFingerprintEnabled();
    
    if (isEnabled) {
      return '$primaryType authentication is enabled';
    } else {
      return '$primaryType is available but not enabled';
    }
  }
}

class BiometricResult {
  final bool success;
  final String? error;
  
  BiometricResult.success() : success = true, error = null;
  BiometricResult.error(this.error) : success = false;

  @override
  String toString() {
    return success ? 'BiometricResult.success' : 'BiometricResult.error($error)';
  }
}

