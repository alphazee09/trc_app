import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/bazari_api_service.dart';
import '../../core/services/token_manager.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crypto_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start animations
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    
    // Initialize providers
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    
    // Check if user is already authenticated
    bool isAuthenticated = false;
    try {
      isAuthenticated = await BazariApiService.isAuthenticated();
      if (isAuthenticated) {
        final user = await BazariApiService.getUserProfile();
        authProvider.setUser(user.toJson());
      }
    } catch (e) {
      // User not authenticated or error occurred
      isAuthenticated = false;
    }
    
    await Future.wait([
      authProvider.initialize(),
      cryptoProvider.loadCryptoPrices(),
    ]);
    
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Navigate to appropriate screen
    if (mounted) {
      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundColor,
                  AppTheme.surfaceColor.withOpacity(_backgroundAnimation.value),
                  AppTheme.primaryColor.withOpacity(_backgroundAnimation.value * 0.3),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // App Icon/Logo
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // App Name with Animation
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      AppConstants.appName,
                                      textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                ),
                                const SizedBox(height: 8),
                                
                                // App Description
                                Text(
                                  AppConstants.appDescription,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Loading Section
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Loading Indicator
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Loading Text
                        AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              'Initializing...',
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              duration: const Duration(milliseconds: 1000),
                            ),
                            FadeAnimatedText(
                              'Loading crypto prices...',
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              duration: const Duration(milliseconds: 1000),
                            ),
                            FadeAnimatedText(
                              'Preparing your wallet...',
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              duration: const Duration(milliseconds: 1000),
                            ),
                          ],
                          repeatForever: true,
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Secure • Fast • Reliable',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version ${AppConstants.appVersion}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

