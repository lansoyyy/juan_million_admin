import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class MemberAffiliateReportPage extends StatelessWidget {
  const MemberAffiliateReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: blue,
          title: TextWidget(
            text: 'Member & Affiliate List',
            fontSize: 18,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Affiliates'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MembersTab(),
            _AffiliatesTab(),
          ],
        ),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading members'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No members found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '') as String;
            final email = (data['email'] ?? '') as String;
            final pic = (data['pic'] ?? '') as String;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                child: pic.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: TextWidget(
                text: name,
                fontSize: 14,
                fontFamily: 'Bold',
              ),
              subtitle: TextWidget(
                text: email,
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.grey,
              ),
              onTap: () => _showMemberDetails(context, doc),
            );
          },
        );
      },
    );
  }

  void _showMemberDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] ?? '') as String;
    final email = (data['email'] ?? '') as String;
    final pic = (data['pic'] ?? '') as String;
    final createdAt = data['createdAt'];

    DateTime? createdDate;
    if (createdAt is Timestamp) {
      createdDate = createdAt.toDate();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Member Details',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 400,
            child: FutureBuilder<_RecentActivitySummary>(
              future: _loadRecentActivity(doc.id, isBusiness: false),
              builder: (context, snapshot) {
                final activity = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              pic.isNotEmpty ? NetworkImage(pic) : null,
                          child: pic.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: name,
                                fontSize: 16,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: email,
                                fontSize: 12,
                                fontFamily: 'Regular',
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Registration Date',
                      fontSize: 12,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: createdDate != null
                          ? DateFormat.yMMMd().format(createdDate)
                          : 'Not available',
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Recent Activity (last 15 days)',
                      fontSize: 12,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 4),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator()
                    else if (activity == null)
                      const Text('No recent activity data.',
                          style: TextStyle(fontSize: 12))
                    else ...[
                      TextWidget(
                        text: 'Wallet transactions: ${activity.walletCount}',
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey,
                      ),
                      TextWidget(
                        text: 'Points events: ${activity.pointsCount}',
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _AffiliatesTab extends StatelessWidget {
  const _AffiliatesTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Business')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading affiliates'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No affiliates found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '') as String;
            final email = (data['email'] ?? '') as String;
            final logo = (data['logo'] ?? '') as String;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                child: logo.isEmpty
                    ? const Icon(Icons.storefront, color: Colors.white)
                    : null,
              ),
              title: TextWidget(
                text: name,
                fontSize: 14,
                fontFamily: 'Bold',
              ),
              subtitle: TextWidget(
                text: email,
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.grey,
              ),
              onTap: () => _showAffiliateDetails(context, doc),
            );
          },
        );
      },
    );
  }

  void _showAffiliateDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] ?? '') as String;
    final email = (data['email'] ?? '') as String;
    final logo = (data['logo'] ?? '') as String;
    final createdAt = data['createdAt'];

    DateTime? createdDate;
    if (createdAt is Timestamp) {
      createdDate = createdAt.toDate();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Affiliate Details',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 400,
            child: FutureBuilder<_RecentActivitySummary>(
              future: _loadRecentActivity(doc.id, isBusiness: true),
              builder: (context, snapshot) {
                final activity = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              logo.isNotEmpty ? NetworkImage(logo) : null,
                          child: logo.isEmpty
                              ? const Icon(Icons.storefront,
                                  color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: name,
                                fontSize: 16,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: email,
                                fontSize: 12,
                                fontFamily: 'Regular',
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Registration Date',
                      fontSize: 12,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: createdDate != null
                          ? DateFormat.yMMMd().format(createdDate)
                          : 'Not available',
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Recent Activity (last 15 days)',
                      fontSize: 12,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 4),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator()
                    else if (activity == null)
                      const Text('No recent activity data.',
                          style: TextStyle(fontSize: 12))
                    else ...[
                      TextWidget(
                        text: 'Wallet transactions: ${activity.walletCount}',
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey,
                      ),
                      TextWidget(
                        text: 'Points events: ${activity.pointsCount}',
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _RecentActivitySummary {
  final int walletCount;
  final int pointsCount;

  _RecentActivitySummary(
      {required this.walletCount, required this.pointsCount});
}

Future<_RecentActivitySummary> _loadRecentActivity(String uid,
    {required bool isBusiness}) async {
  final now = DateTime.now();
  final fromDate = now.subtract(const Duration(days: 15));

  final walletsSnap = await FirebaseFirestore.instance
      .collection('Wallets')
      .where('dateTime', isGreaterThanOrEqualTo: fromDate)
      .where('uid', isEqualTo: uid)
      .get();

  final pointsQuery = isBusiness
      ? FirebaseFirestore.instance
          .collection('Points')
          .where('dateTime', isGreaterThanOrEqualTo: fromDate)
          .where('uid', isEqualTo: uid)
      : FirebaseFirestore.instance
          .collection('Points')
          .where('dateTime', isGreaterThanOrEqualTo: fromDate)
          .where('scannedId', isEqualTo: uid);

  final pointsSnap = await pointsQuery.get();

  return _RecentActivitySummary(
    walletCount: walletsSnap.docs.length,
    pointsCount: pointsSnap.docs.length,
  );
}
