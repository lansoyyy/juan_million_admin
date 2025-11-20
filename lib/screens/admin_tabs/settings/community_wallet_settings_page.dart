import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CommunityWalletSettingsPage extends StatefulWidget {
  const CommunityWalletSettingsPage({super.key});

  @override
  State<CommunityWalletSettingsPage> createState() =>
      _CommunityWalletSettingsPageState();
}

class _CommunityWalletSettingsPageState
    extends State<CommunityWalletSettingsPage> {
  final totalRewardsController = TextEditingController();
  final capacityController = TextEditingController();
  final companyPercentController = TextEditingController();
  final itPercentController = TextEditingController();
  final rewardsPercentController = TextEditingController();

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('settings')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        totalRewardsController.text = (data['totalRewards'] ?? '').toString();
        capacityController.text = (data['capacity'] ?? '').toString();
        companyPercentController.text =
            (data['companyPercent'] ?? '').toString();
        itPercentController.text = (data['itPercent'] ?? '').toString();
        rewardsPercentController.text =
            (data['rewardsPercent'] ?? '').toString();
      }
    } finally {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    final company = double.tryParse(companyPercentController.text) ?? 0;
    final it = double.tryParse(itPercentController.text) ?? 0;
    final rewards = double.tryParse(rewardsPercentController.text) ?? 0;
    final totalPercent = company + it + rewards;

    if (totalPercent != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Allocation percentages must total 100%.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('Community Wallet')
        .doc('settings')
        .set({
      'totalRewards': double.tryParse(totalRewardsController.text) ?? 0,
      'capacity': double.tryParse(capacityController.text) ?? 0,
      'companyPercent': company,
      'itPercent': it,
      'rewardsPercent': rewards,
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Community wallet settings saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Community Wallet Management',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Rewards Configuration',
                    fontSize: 16,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text:
                        'Define the total rewards pool, community wallet capacity, and allocation percentages.',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.grey,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                      'Total Rewards Amount', totalRewardsController,
                      hint: 'e.g. 100000'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                      'Community Wallet Capacity', capacityController,
                      hint: 'Max points in community wallet'),
                  const SizedBox(height: 24),
                  TextWidget(
                    text: 'Allocation Percentages',
                    fontSize: 16,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          'Company %',
                          companyPercentController,
                          hint: 'e.g. 70',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          'IT %',
                          itPercentController,
                          hint: 'e.g. 5',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          'Rewards Fund %',
                          rewardsPercentController,
                          hint: 'e.g. 25',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style:
                            TextStyle(fontFamily: 'Bold', color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: label,
          fontSize: 12,
          fontFamily: 'Medium',
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
