import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/crypto_provider.dart';
import '../../widgets/common/crypto_price_card.dart';
import '../../core/services/wallet_service.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '24H';
  final List<String> _timeframes = ['1H', '24H', '7D', '30D'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    await cryptoProvider.loadPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Gainers'),
            Tab(text: 'Losers'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<CryptoProvider>(
          builder: (context, cryptoProvider, child) {
            if (cryptoProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Market Overview
                _buildMarketOverview(cryptoProvider),
                
                // Timeframe Selector
                _buildTimeframeSelector(),
                
                // Price List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPriceList(cryptoProvider.prices),
                      _buildPriceList(cryptoProvider.topGainers),
                      _buildPriceList(cryptoProvider.topLosers),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketOverview(CryptoProvider cryptoProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Market Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMarketStat(
                  'Market Cap',
                  cryptoProvider.formatMarketCap(cryptoProvider.totalMarketCap),
                  Icons.pie_chart,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textTertiary.withOpacity(0.3),
              ),
              Expanded(
                child: _buildMarketStat(
                  '24h Volume',
                  cryptoProvider.formatVolume(cryptoProvider.total24hVolume),
                  Icons.bar_chart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _timeframes.map((timeframe) {
          final isSelected = _selectedTimeframe == timeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = timeframe;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeframe,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceList(List<CryptoPriceModel> prices) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prices.length,
        itemBuilder: (context, index) {
          final price = prices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CryptoPriceCard(
              price: price,
              onTap: () {
                _showPriceDetails(price);
              },
            ),
          );
        },
      ),
    );
  }

  void _showPriceDetails(CryptoPriceModel price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPriceDetailsSheet(price),
    );
  }

  Widget _buildPriceDetailsSheet(CryptoPriceModel price) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: _getCryptoGradient(price.symbol),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getCryptoIcon(price.symbol),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price.symbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(price.priceUsd),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          price.change24h >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: price.change24h >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${price.change24h >= 0 ? '+' : ''}${price.change24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: price.change24h >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chart Placeholder
          Container(
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price Chart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  Text(
                    'Coming Soon',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Stats
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Market Cap', _formatMarketCap(price.marketCap)),
                  _buildStatRow('24h Volume', _formatVolume(price.volume24h)),
                  _buildStatRow('24h Change', '${price.change24h >= 0 ? '+' : ''}${price.change24h.toStringAsFixed(2)}%'),
                  _buildStatRow('Current Price', _formatPrice(price.priceUsd)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getCryptoGradient(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return const LinearGradient(
          colors: [Color(0xFFF7931A), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'USDT':
        return const LinearGradient(
          colors: [Color(0xFF26A17B), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ETH':
        return const LinearGradient(
          colors: [Color(0xFF627EEA), Color(0xFF8E9AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  String _getCryptoIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'USDT':
        return '₮';
      case 'ETH':
        return 'Ξ';
      case 'BNB':
        return 'B';
      case 'ADA':
        return 'A';
      case 'SOL':
        return 'S';
      case 'DOT':
        return 'D';
      case 'DOGE':
        return 'Ð';
      default:
        return symbol.substring(0, 1);
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(0)}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 0.01) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }

  String _formatMarketCap(double? marketCap) {
    if (marketCap == null) return 'N/A';
    if (marketCap >= 1e12) {
      return '\$${(marketCap / 1e12).toStringAsFixed(2)}T';
    } else if (marketCap >= 1e9) {
      return '\$${(marketCap / 1e9).toStringAsFixed(2)}B';
    } else if (marketCap >= 1e6) {
      return '\$${(marketCap / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${marketCap.toStringAsFixed(0)}';
    }
  }

  String _formatVolume(double? volume) {
    if (volume == null) return 'N/A';
    if (volume >= 1e9) {
      return '\$${(volume / 1e9).toStringAsFixed(2)}B';
    } else if (volume >= 1e6) {
      return '\$${(volume / 1e6).toStringAsFixed(2)}M';
    } else if (volume >= 1e3) {
      return '\$${(volume / 1e3).toStringAsFixed(2)}K';
    } else {
      return '\$${volume.toStringAsFixed(0)}';
    }
  }
}

