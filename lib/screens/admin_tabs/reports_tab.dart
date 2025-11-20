import 'package:flutter/material.dart';
import 'package:juan_million/screens/admin_tabs/reports/member_affiliate_report_page.dart';
import 'package:juan_million/screens/admin_tabs/reports/coordinator_report_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : 2;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Reports',
                  fontSize: isMobile ? 20 : 24,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text:
                      'View member, affiliate, and coordinator reports with recent activity.',
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
                      _buildReportCard(
                        context,
                        title: 'Member & Affiliate List',
                        description:
                            'List all registered members and affiliates, with drill-down details.',
                        icon: Icons.people,
                        color: primary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MemberAffiliateReportPage(),
                            ),
                          );
                        },
                      ),
                      _buildReportCard(
                        context,
                        title: 'Coordinator Report',
                        description:
                            'View coordinators, their details, and affiliated businesses.',
                        icon: Icons.supervisor_account,
                        color: blue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CoordinatorReportPage(),
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

  Widget _buildReportCard(
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
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
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
