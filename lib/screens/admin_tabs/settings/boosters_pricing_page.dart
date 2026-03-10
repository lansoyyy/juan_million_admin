import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class BoostersPricingPage extends StatelessWidget {
  const BoostersPricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Boosters Pricing',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBoosterDialog(context),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: TextWidget(
          text: 'Add Booster',
          fontSize: 13,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Boosters').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading boosters'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = (snapshot.data?.docs ?? []).toList();
          docs.sort((a, b) {
            final dynamic aPrice = a['price'];
            final dynamic bPrice = b['price'];
            final num aNum = aPrice is num ? aPrice : 0;
            final num bNum = bPrice is num ? bPrice : 0;
            return aNum.compareTo(bNum);
          });

          if (docs.isEmpty) {
            return Center(
              child: TextWidget(
                text: 'No boosters configured',
                fontSize: 14,
                color: Colors.grey,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final num price = (data['price'] ?? 0) is num
                  ? data['price'] as num
                  : 0;
              final num slots = (data['slots'] ?? 0) is num
                  ? data['slots'] as num
                  : 0;

              return Card(
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(Icons.sell, color: primary),
                  ),
                  title: TextWidget(
                    text: 'P${price.toString()}',
                    fontSize: 15,
                    fontFamily: 'Bold',
                  ),
                  subtitle: TextWidget(
                    text: 'Slots: ${slots.toString()}',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showBoosterDialog(
                          context,
                          docId: doc.id,
                          existingPrice: price,
                          existingSlots: slots,
                        ),
                        icon: Icon(Icons.edit, color: blue),
                      ),
                      IconButton(
                        onPressed: () => _deleteBooster(context, doc.id),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteBooster(BuildContext context, String docId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Delete Booster',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: TextWidget(
            text: 'Are you sure you want to delete this booster?',
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: TextWidget(text: 'Cancel', fontSize: 13),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: TextWidget(
                text: 'Delete',
                fontSize: 13,
                fontFamily: 'Bold',
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Boosters')
          .doc(docId)
          .delete();
      showToast('Booster deleted', type: ToastType.success);
    } catch (_) {
      showToast('Failed to delete booster', type: ToastType.error);
    }
  }

  Future<void> _showBoosterDialog(
    BuildContext context, {
    String? docId,
    num? existingPrice,
    num? existingSlots,
  }) async {
    final priceController = TextEditingController(
      text: existingPrice?.toString() ?? '',
    );
    final slotsController = TextEditingController(
      text: existingSlots?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: docId == null ? 'Add Booster' : 'Edit Booster',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: slotsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Slots',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: TextWidget(text: 'Cancel', fontSize: 13),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? price = int.tryParse(priceController.text.trim());
                final double? slots = double.tryParse(
                  slotsController.text.trim(),
                );

                if (price == null ||
                    price <= 0 ||
                    slots == null ||
                    slots <= 0) {
                  showToast(
                    'Please enter valid price and slots',
                    type: ToastType.error,
                  );
                  return;
                }

                final targetDoc = docId == null
                    ? FirebaseFirestore.instance.collection('Boosters').doc()
                    : FirebaseFirestore.instance
                          .collection('Boosters')
                          .doc(docId);

                try {
                  await targetDoc.set({
                    'id': targetDoc.id,
                    'price': price,
                    'slots': slots,
                    'dateTime': DateTime.now(),
                  }, SetOptions(merge: true));

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  showToast(
                    docId == null ? 'Booster added' : 'Booster updated',
                    type: ToastType.success,
                  );
                } catch (_) {
                  showToast('Failed to save booster', type: ToastType.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              child: TextWidget(
                text: 'Save',
                fontSize: 13,
                fontFamily: 'Bold',
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
