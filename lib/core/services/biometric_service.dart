import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

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
        return 'No biometric credentials are enrolled on this device';
      case 'LockedOut':
        return 'Biometric authentication is temporarily locked out';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is permanently locked out';
      case 'UserCancel':
        return 'User cancelled biometric authentication';
      case 'UserFallback':
        return 'User chose to use fallback authentication';
      case 'SystemCancel':
        return 'System cancelled biometric authentication';
      case 'InvalidContext':
        return 'Invalid authentication context';
      case 'NotSupported':
        return 'Biometric authentication is not supported on this device';
      default:
        return 'Biometric authentication error: ${e.message}';
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
    
    // Prioritize face recognition, then fingerprint
    if (biometrics.contains(BiometricType.face)) {
      return getBiometricTypeString(BiometricType.face);
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return getBiometricTypeString(BiometricType.fingerprint);
    } else {
      return getBiometricTypeString(biometrics.first);
    }
  }
}

class BiometricResult {
  final bool success;
  final String? error;
  
  BiometricResult.success() : success = true, error = null;
  BiometricResult.error(this.error) : success = false;
}

