import 'package:flutter/material.dart';
import 'package:juan_million/screens/admin_tabs/settings/coordinator_settings_page.dart';
import 'package:juan_million/screens/admin_tabs/settings/community_wallet_settings_page.dart';
import 'package:juan_million/screens/admin_tabs/settings/affiliate_display_settings_page.dart';
import 'package:juan_million/screens/admin_tabs/settings/signup_defaults_page.dart';
import 'package:juan_million/screens/admin_tabs/settings/boosters_pricing_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class TemplatesTab extends StatelessWidget {
  const TemplatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : 3;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Templates & Settings',
                  fontSize: isMobile ? 20 : 24,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text:
                      'Configure onboarding defaults, coordinator approvals, community wallet rules, and booster pricing.',
                  fontSize: isMobile ? 12 : 14,
                  fontFamily: 'Regular',
                  color: Colors.grey,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 4 / 3 : 3 / 2,
                    children: [
                      _buildTemplateCard(
                        context,
                        title: 'Global Signup Defaults',
                        description:
                            'Set default starting values for new affiliate and coordinator accounts.',
                        icon: Icons.tune,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupDefaultsPage(),
                            ),
                          );
                        },
                      ),
                      _buildTemplateCard(
                        context,
                        title: 'Coordinator Settings',
                        description:
                            'Manage coordinator registration approvals and upload standard contracts.',
                        icon: Icons.verified_user,
                        color: primary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CoordinatorSettingsPage(),
                            ),
                          );
                        },
                      ),
                      _buildTemplateCard(
                        context,
                        title: 'Community Wallet Management',
                        description:
                            'Set rewards totals, capacity, and allocation percentages for company, IT, and rewards.',
                        icon: Icons.account_balance_wallet,
                        color: blue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CommunityWalletSettingsPage(),
                            ),
                          );
                        },
                      ),
                      _buildTemplateCard(
                        context,
                        title: 'Boosters Pricing',
                        description:
                            'Create, edit, and remove booster packages used in all store pages.',
                        icon: Icons.price_change,
                        color: Colors.deepOrange,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BoostersPricingPage(),
                            ),
                          );
                        },
                      ),
                      _buildTemplateCard(
                        context,
                        title: 'Affiliate Display Settings',
                        description:
                            'Choose which affiliates are featured on the member dashboard.',
                        icon: Icons.storefront,
                        color: secondary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AffiliateDisplaySettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: title,
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: description,
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
