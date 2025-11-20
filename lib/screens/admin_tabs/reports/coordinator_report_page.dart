import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CoordinatorReportPage extends StatelessWidget {
  const CoordinatorReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Coordinator Report',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Coordinator')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading coordinators'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No coordinators found.'));
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
              final approved = (data['approved'] ?? false) as bool;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: approved ? Colors.green : Colors.orange,
                  child:
                      const Icon(Icons.supervisor_account, color: Colors.white),
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
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: approved
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextWidget(
                    text: approved ? 'Approved' : 'Pending',
                    fontSize: 10,
                    fontFamily: 'Bold',
                    color: approved ? Colors.green : Colors.orange,
                  ),
                ),
                onTap: () => _showCoordinatorDetails(context, doc),
              );
            },
          );
        },
      ),
    );
  }

  void _showCoordinatorDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] ?? '') as String;
    final email = (data['email'] ?? '') as String;
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
            text: 'Coordinator Details',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 16),
                TextWidget(
                  text: 'Affiliates under this coordinator',
                  fontSize: 12,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 4),
                const Text(
                  'Listing of affiliates assigned to this coordinator can be added once the linkage schema (e.g., referral code or coordinatorId field on Business) is finalized.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
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
