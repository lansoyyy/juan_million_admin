import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class AffiliateDisplaySettingsPage extends StatelessWidget {
  const AffiliateDisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Affiliate Display Settings',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Featured Affiliates',
              fontSize: 16,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text:
                  'Select which affiliates (Business accounts) should be highlighted on the member dashboard.',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Business')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading affiliates'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No affiliates found.'));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '') as String;
                      final clarification =
                          (data['clarification'] ?? '') as String;
                      final featured = (data['featured'] ?? false) as bool;

                      return SwitchListTile(
                        title: TextWidget(
                          text: name,
                          fontSize: 14,
                          fontFamily: 'Bold',
                        ),
                        subtitle: TextWidget(
                          text: clarification,
                          fontSize: 12,
                          fontFamily: 'Regular',
                          color: Colors.grey,
                        ),
                        value: featured,
                        onChanged: (value) {
                          FirebaseFirestore.instance
                              .collection('Business')
                              .doc(doc.id)
                              .update({'featured': value});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
