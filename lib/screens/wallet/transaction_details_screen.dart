import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/transaction_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Note: In a real app, you'd show a snackbar here
  }

  Future<void> _openExplorer() async {
    final url = transaction.explorerUrl;
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (transaction.explorerUrl.isNotEmpty)
            IconButton(
              onPressed: _openExplorer,
              icon: const Icon(Icons.open_in_new),
              tooltip: 'View on Explorer',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Status Header
              _buildStatusHeader(),
              const SizedBox(height: 24),
              
              // Transaction Amount
              _buildAmountSection(),
              const SizedBox(height: 24),
              
              // Transaction Details
              _buildDetailsSection(),
              const SizedBox(height: 24),
              
              // Blockchain Details
              if (transaction.blockNumber != null) ...[
                _buildBlockchainSection(),
                const SizedBox(height: 24),
              ],
              
              // Gas Details (for ETH/USDT)
              if (transaction.gasUsed != null) ...[
                _buildGasSection(),
                const SizedBox(height: 24),
              ],
              
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    IconData statusIcon;
    
    if (transaction.isConfirmed) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
    } else if (transaction.isPending) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              statusIcon,
              size: 40,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.statusDisplayText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transaction.typeDisplayText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (transaction.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDateTime(transaction.createdAt!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                transaction.currencyIcon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                '${transaction.isSent ? '-' : '+'}${transaction.formattedAmount}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isSent ? AppTheme.errorColor : AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                transaction.currency,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Network Fee: ${transaction.formattedFee} ${transaction.currency}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Transaction ID', transaction.shortTxHash, transaction.txHash),
          _buildDetailRow('From', transaction.shortFromAddress, transaction.fromAddress),
          _buildDetailRow('To', transaction.shortToAddress, transaction.toAddress),
          _buildDetailRow('Amount', '${transaction.formattedAmount} ${transaction.currency}'),
          _buildDetailRow('Fee', '${transaction.formattedFee} ${transaction.currency}'),
          _buildDetailRow('Status', transaction.statusDisplayText),
          if (transaction.createdAt != null)
            _buildDetailRow('Date', _formatDateTime(transaction.createdAt!)),
          if (transaction.confirmedAt != null)
            _buildDetailRow('Confirmed', _formatDateTime(transaction.confirmedAt!)),
        ],
      ),
    );
  }

  Widget _buildBlockchainSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blockchain Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (transaction.blockNumber != null)
            _buildDetailRow('Block Number', transaction.blockNumber.toString()),
          if (transaction.blockHash != null)
            _buildDetailRow('Block Hash', transaction.shortBlockHash, transaction.blockHash),
          if (transaction.contractAddress != null)
            _buildDetailRow('Contract', transaction.contractAddress!),
          if (transaction.tokenId != null)
            _buildDetailRow('Token ID', transaction.tokenId!),
        ],
      ),
    );
  }

  Widget _buildGasSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gas Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (transaction.gasUsed != null)
            _buildDetailRow('Gas Used', transaction.gasUsed.toString()),
          if (transaction.gasPrice != null)
            _buildDetailRow('Gas Price', transaction.formattedGasPrice),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [String? fullValue]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: fullValue != null ? () => _copyToClipboard(fullValue, label) : null,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: fullValue != null ? 'monospace' : null,
                  color: fullValue != null ? AppTheme.primaryColor : null,
                ),
              ),
            ),
          ),
          if (fullValue != null)
            GestureDetector(
              onTap: () => _copyToClipboard(fullValue, label),
              child: Icon(
                Icons.copy,
                size: 16,
                color: AppTheme.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (transaction.explorerUrl.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openExplorer,
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on Blockchain Explorer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(transaction.txHash, 'Transaction ID'),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Transaction ID'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

