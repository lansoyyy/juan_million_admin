import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';

import '../../../widgets/text_widget.dart';

import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class CoordinatorWallets extends StatefulWidget {
  const CoordinatorWallets({super.key});

  @override
  State<CoordinatorWallets> createState() => _CoordinatorWalletsState();
}

class _CoordinatorWalletsState extends State<CoordinatorWallets> {
  final searchController = TextEditingController();
  String nameSearched = '';

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
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Coordinator')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }

                          final data = snapshot.data;
                          if (data == null) {
                            return TextWidget(
                              text: '0 Total Coordinators',
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: Colors.black,
                            );
                          }
                          return TextWidget(
                            text:
                                '${data.docs.length.toString()} Total Coordinators',
                            fontSize: 14,
                            fontFamily: 'Regular',
                            color: Colors.black,
                          );
                        }),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Coordinator')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }

                          final data = snapshot.data;
                          if (data == null) {
                            return TextWidget(
                              text: AppConstants.formatNumberWithPeso(0),
                              fontSize: 28,
                              fontFamily: 'Bold',
                              color: primary,
                            );
                          }

                          List itemData = data.docs;
                          int total = 0;

                          for (int i = 0; i < itemData.length; i++) {
                            final wallet = itemData[i]['wallet'];
                            if (wallet != null) {
                              total += int.parse(wallet.toString());
                            }
                          }
                          return TextWidget(
                            text: AppConstants.formatNumberWithPeso(total),
                            fontSize: 28,
                            fontFamily: 'Bold',
                            color: primary,
                          );
                        }),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(100)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Regular',
                            fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            nameSearched = value;
                          });
                        },
                        decoration: const InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            hintText: 'Search Coordinators',
                            hintStyle: TextStyle(fontFamily: 'Bold'),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            )),
                        controller: searchController,
                      ),
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Coordinator')
                        .where('name',
                            isGreaterThanOrEqualTo:
                                toBeginningOfSentenceCase(nameSearched))
                        .where('name',
                            isLessThan:
                                '${toBeginningOfSentenceCase(nameSearched)}z')
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

                      final data = snapshot.data;
                      if (data == null || data.docs.isEmpty) {
                        return const Center(
                          child: Text('No coordinators found.'),
                        );
                      }

                      return DataTable(columns: [
                        DataColumn(
                          label: TextWidget(
                            text: 'No.',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Name',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Wallet',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ], rows: [
                        for (int i = 0; i < data.docs.length; i++)
                          DataRow(cells: [
                            DataCell(
                              TextWidget(
                                text: '${i + 1}',
                                fontSize: 14,
                              ),
                            ),
                            DataCell(GestureDetector(
                              onTap: () {
                                showDetails(data.docs[i]);
                              },
                              child: TextWidget(
                                text: data.docs[i]['name'] ?? 'No Name',
                                fontSize: 14,
                              ),
                            )),
                            DataCell(TextWidget(
                              text: AppConstants.formatNumberWithPeso(
                                  data.docs[i]['wallet'] ?? 0),
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

  showDetails(data) {
    final approved = data['approved'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: approved ? Colors.green : Colors.orange,
                child: const Icon(
                  Icons.supervisor_account,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextWidget(
                text: data['name'] ?? 'No Name',
                fontSize: 18,
                fontFamily: 'Bold',
              ),
              TextWidget(
                text: data['email'] ?? 'No Email',
                fontSize: 12,
                fontFamily: 'Medium',
              ),
              const Divider(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: approved
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextWidget(
                  text: approved ? 'Approved' : 'Pending',
                  fontSize: 12,
                  fontFamily: 'Bold',
                  color: approved ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: 'Wallet Balance',
                fontSize: 14,
                fontFamily: 'Regular',
                color: Colors.grey,
              ),
              TextWidget(
                text: AppConstants.formatNumberWithPeso(data['wallet'] ?? 0),
                fontSize: 24,
                fontFamily: 'Bold',
                color: primary,
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
          ],
        );
      },
    );
  }
}
