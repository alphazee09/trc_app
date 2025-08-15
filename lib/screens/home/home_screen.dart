import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/crypto_price_card.dart';
import '../../widgets/common/wallet_balance_card.dart';
import '../../widgets/common/quick_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    
    await Future.wait([
      walletProvider.loadWallets(),
      walletProvider.loadTransactions(),
      cryptoProvider.loadPrices(),
    ]);
    
    // Start auto-refresh for crypto prices
    cryptoProvider.startAutoRefresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    cryptoProvider.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBody(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildWalletTab();
      case 2:
        return _buildMarketsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Portfolio Overview
            _buildPortfolioOverview(),
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),
            
            // Market Overview
            _buildMarketOverview(),
            const SizedBox(height: 24),
            
            // Recent Transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return RefreshIndicator(
          onRefresh: () => walletProvider.loadWallets(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Wallets',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/send');
                          },
                          icon: const Icon(Icons.send),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/receive');
                          },
                          icon: const Icon(Icons.call_received),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Wallet Cards
                if (walletProvider.wallets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No wallets found',
                        style: TextStyle(color: AppTheme.textTertiary),
                      ),
                    ),
                  )
                else
                  ...walletProvider.wallets.map((wallet) {
                    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
                    final usdValue = cryptoProvider.getUSDValue(wallet.currency, wallet.balance);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WalletBalanceCard(
                        wallet: wallet,
                        usdValue: usdValue,
                        onTap: () {
                          // TODO: Navigate to wallet details
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketsTab() {
    return Consumer<CryptoProvider>(
      builder: (context, cryptoProvider, child) {
        if (cryptoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: () => cryptoProvider.loadPrices(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Cryptocurrency Markets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Market Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Market Cap',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cryptoProvider.formatMarketCap(cryptoProvider.totalMarketCap),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.textTertiary.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '24h Volume',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cryptoProvider.formatVolume(cryptoProvider.total24hVolume),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Price List
                ...cryptoProvider.prices.map((price) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CryptoPriceCard(price: price),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
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
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/kyc');
                      },
                      icon: const Icon(Icons.verified_user),
                      label: const Text('KYC'),
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Row(
          children: [
            // Profile Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(25),
              ),
              child: user?.profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
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
                                fontSize: 18,
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
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Welcome Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    user?.fullName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification Icon
            IconButton(
              onPressed: () {
                // TODO: Implement notifications
              },
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPortfolioOverview() {
    return Consumer2<WalletProvider, CryptoProvider>(
      builder: (context, walletProvider, cryptoProvider, child) {
        double totalValue = 0.0;
        for (final wallet in walletProvider.wallets) {
          totalValue += cryptoProvider.getUSDValue(wallet.currency, wallet.balance);
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Portfolio Value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Portfolio Chart (Placeholder)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Portfolio Chart',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.send,
                label: 'Send',
                color: AppTheme.primaryColor,
                onTap: () {
                  // TODO: Navigate to send screen
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.call_received,
                label: 'Receive',
                color: AppTheme.successColor,
                onTap: () {
                  // TODO: Navigate to receive screen
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.swap_horiz,
                label: 'Swap',
                color: AppTheme.secondaryColor,
                onTap: () {
                  // TODO: Navigate to swap screen
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.more_horiz,
                label: 'More',
                color: AppTheme.warningColor,
                onTap: () {
                  // TODO: Show more options
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketOverview() {
    return Consumer<CryptoProvider>(
      builder: (context, cryptoProvider, child) {
        if (cryptoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final supportedPrices = cryptoProvider.supportedCurrencies;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...supportedPrices.map((price) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CryptoPriceCard(price: price),
            )),
          ],
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final recentTransactions = walletProvider.recentTransactions.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                ),
              )
            else
              ...recentTransactions.map((transaction) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: transaction.isSent ? AppTheme.errorColor : AppTheme.successColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        transaction.isSent ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${transaction.typeDisplayText} ${transaction.currency}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            transaction.shortTxHash,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.isSent ? '-' : '+'}${transaction.formattedAmount} ${transaction.currency}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: transaction.isSent ? AppTheme.errorColor : AppTheme.successColor,
                          ),
                        ),
                        Text(
                          transaction.statusDisplayText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: transaction.isConfirmed ? AppTheme.successColor : AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

