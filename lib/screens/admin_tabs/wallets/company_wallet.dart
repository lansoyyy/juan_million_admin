import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

import '../../../widgets/text_widget.dart';

import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class CompanyWallet extends StatefulWidget {
  int total;

  CompanyWallet({
    super.key,
    required this.total,
  });

  @override
  State<CompanyWallet> createState() => _CompanyWalletState();
}

class _CompanyWalletState extends State<CompanyWallet> {
  final amount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
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
                                        if (widget.total >
                                            int.parse(amount.text)) {
                                          await FirebaseFirestore.instance
                                              .collection('Community Wallet')
                                              .doc('business')
                                              .update({
                                            'pts': FieldValue.increment(
                                                -int.parse(amount.text))
                                          });
                                        } else {
                                          showToast('Insufficient balance!');
                                        }

                                        Navigator.pop(context);
                                      },
                                      child: TextWidget(
                                        text: 'Continue',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.input,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('History')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          )),
                        );
                      }

                      final data = snapshot.requireData;
                      if (data.docs.isEmpty) {
                        return const Center(
                          child: Text('No transactions found'),
                        );
                      }

                      return DataTable(columns: [
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
                      ], rows: [
                        for (int i = 0; i < data.docs.length; i++)
                          DataRow(cells: [
                            DataCell(TextWidget(
                              text: data.docs[i]['name'],
                              fontSize: 14,
                            )),
                            DataCell(TextWidget(
                              text: 'P 5,500',
                              fontSize: 14,
                            )),
                            DataCell(TextWidget(
                              text: 'P 2,400',
                              fontSize: 14,
                            )),
                          ])
                      ]);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
