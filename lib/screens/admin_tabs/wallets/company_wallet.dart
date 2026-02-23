import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

import '../../../widgets/text_widget.dart';

class CompanyWallet extends StatefulWidget {
  final int total;

  const CompanyWallet({super.key, required this.total});

  @override
  State<CompanyWallet> createState() => _CompanyWalletState();
}

class _CompanyWalletState extends State<CompanyWallet> {
  final amount = TextEditingController();
  bool isProcessing = false;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Total Company Income',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      TextWidget(
                        text: AppConstants.formatNumberWithPeso(widget.total),
                        fontSize: 28,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFieldWidget(
                                      inputType: TextInputType.number,
                                      controller: amount,
                                      label: 'Enter cashout amount',
                                      hint: 'Enter cashout amount',
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: TextWidget(
                                      text: 'Close',
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (isProcessing) return;

                                      if (amount.text.isEmpty) {
                                        showToast('Please enter an amount');
                                        return;
                                      }

                                      final cashoutAmount =
                                          int.tryParse(amount.text);
                                      if (cashoutAmount == null) {
                                        showToast(
                                            'Please enter a valid number');
                                        return;
                                      }

                                      if (cashoutAmount <= 0) {
                                        showToast(
                                            'Amount must be greater than 0');
                                        return;
                                      }

                                      if (widget.total < cashoutAmount) {
                                        showToast('Insufficient balance!');
                                        return;
                                      }

                                      final navigator = Navigator.of(context);
                                      setState(() {
                                        isProcessing = true;
                                      });

                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('Community Wallet')
                                            .doc('business')
                                            .update({
                                          'pts': FieldValue.increment(
                                              -cashoutAmount),
                                        });
                                        if (mounted) {
                                          showToast('Cashout successful!');
                                          amount.clear();
                                          navigator.pop();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          showToast(
                                              'Error processing cashout: ${e.toString()}');
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isProcessing = false;
                                          });
                                        }
                                      }
                                    },
                                    child: isProcessing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.blue,
                                            ),
                                          )
                                        : TextWidget(
                                            text: 'Continue',
                                            fontSize: 14,
                                          ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.input, color: primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('History')
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading data'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data;
                  if (data == null || data.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Text('No transactions found')),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: TextWidget(
                            text: 'Member',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Received',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Company Income',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ],
                      rows: data.docs.map((doc) {
                        final docData = doc.data() as Map<String, dynamic>?;
                        if (docData == null) {
                          return const DataRow(
                            cells: [
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                            ],
                          );
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              TextWidget(
                                text: docData['name']?.toString() ?? 'Unknown',
                                fontSize: 14,
                              ),
                            ),
                            DataCell(
                              TextWidget(
                                text: AppConstants.formatNumberWithPeso(
                                  docData['received'] ?? 0,
                                ),
                                fontSize: 14,
                              ),
                            ),
                            DataCell(
                              TextWidget(
                                text: AppConstants.formatNumberWithPeso(
                                  docData['companyIncome'] ?? 0,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
