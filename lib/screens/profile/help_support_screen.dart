import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/custom_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'General';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ', icon: Icon(Icons.quiz)),
            Tab(text: 'Contact', icon: Icon(Icons.support_agent)),
            Tab(text: 'Tickets', icon: Icon(Icons.confirmation_number)),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: AnimatedBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFAQTab(),
            _buildContactTab(),
            _buildTicketsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTab() {
    final faqs = [
      {
        'question': 'How do I send cryptocurrency?',
        'answer': 'To send crypto, navigate to your wallet, tap "Send", enter the recipient address and amount. Note: KYC verification is required for sending.'
      },
      {
        'question': 'How do I receive cryptocurrency?',
        'answer': 'Go to your wallet and tap "Receive" to view your QR code and wallet address. Share this with the sender.'
      },
      {
        'question': 'What is KYC verification?',
        'answer': 'Know Your Customer (KYC) is a verification process required by regulations. Complete it in Settings > KYC to unlock sending features.'
      },
      {
        'question': 'How do I enable fingerprint authentication?',
        'answer': 'Go to Settings > Security > Fingerprint Authentication. Your device must support biometric authentication.'
      },
      {
        'question': 'What networks are supported?',
        'answer': 'We support Bitcoin network for BTC and Ethereum network (ERC-20) for ETH and USDT.'
      },
      {
        'question': 'Are my funds safe?',
        'answer': 'Yes! We use industry-standard security measures including secure key storage and biometric authentication.'
      },
      {
        'question': 'How do I backup my wallet?',
        'answer': 'Your wallet is securely backed up on our servers. Keep your login credentials safe and enable 2FA for extra security.'
      },
      {
        'question': 'What are the transaction fees?',
        'answer': 'Transaction fees vary by network congestion. BTC and ETH fees are dynamic, while USDT uses Ethereum network fees.'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return _buildFAQItem(faq['question']!, faq['answer']!);
      },
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send us a message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll get back to you within 24 hours',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Category selection
            const Text(
              'Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: Colors.white),
                  items: [
                    'General',
                    'Account Issues',
                    'Transaction Problems',
                    'KYC Verification',
                    'Security Concerns',
                    'Technical Support',
                    'Feature Request',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subject field
            const Text(
              'Subject',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Brief description of your issue',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Message field
            const Text(
              'Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Describe your issue in detail...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                if (value.trim().length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isSubmitting ? 'Submitting...' : 'Submit Ticket',
                onPressed: _isSubmitting ? null : _submitTicket,
                backgroundColor: AppTheme.primaryColor,
                icon: Icons.send,
              ),
            ),

            const SizedBox(height: 32),

            // Contact info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Other ways to reach us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfo(
                    Icons.email,
                    'Email',
                    'support@bazari.aygroup.app',
                    () => _copyToClipboard('support@bazari.aygroup.app'),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(
                    Icons.schedule,
                    'Support Hours',
                    '24/7 Available',
                    null,
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(
                    Icons.language,
                    'Languages',
                    'English, Spanish, French',
                    null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.copy,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    // Simulated ticket data
    final tickets = [
      {
        'id': '#T001',
        'subject': 'KYC Verification Issue',
        'status': 'Open',
        'category': 'KYC Verification',
        'date': 'Dec 15, 2024',
        'priority': 'High',
      },
      {
        'id': '#T002',
        'subject': 'Transaction not showing',
        'status': 'In Progress',
        'category': 'Transaction Problems',
        'date': 'Dec 14, 2024',
        'priority': 'Medium',
      },
      {
        'id': '#T003',
        'subject': 'Feature request: Dark mode',
        'status': 'Resolved',
        'category': 'Feature Request',
        'date': 'Dec 12, 2024',
        'priority': 'Low',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Your Support Tickets',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final ticket = tickets[index - 1];
        return _buildTicketItem(ticket);
      },
    );
  }

  Widget _buildTicketItem(Map<String, String> ticket) {
    Color statusColor;
    switch (ticket['status']) {
      case 'Open':
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color priorityColor;
    switch (ticket['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket['id']!,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ticket['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket['subject']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                ticket['category']!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                ticket['date']!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ticket['priority']!,
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Support ticket submitted successfully! We\'ll get back to you soon.'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );

      // Clear form
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'General';
      });

      // Switch to tickets tab
      _tabController.animateTo(2);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('$text copied to clipboard'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}