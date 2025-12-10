import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';

import '../../widgets/text_widget.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  final searchController = TextEditingController();
  String nameSearched = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define responsive breakpoints
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
          final isDesktop = constraints.maxWidth >= 1200;

          // Calculate padding based on screen size
          final horizontalPadding = isMobile
              ? 12.0
              : isTablet
                  ? 20.0
                  : 24.0;
          final verticalPadding = isMobile
              ? 12.0
              : isTablet
                  ? 20.0
                  : 24.0;

          // Calculate font sizes based on screen size
          final titleFontSize = isMobile ? 12.0 : 14.0;
          final balanceFontSize = isMobile ? 24.0 : 32.0;
          final headerFontSize = isMobile ? 14.0 : 16.0;
          final dataFontSize = isMobile ? 12.0 : 14.0;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with wallet balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Community Wallet',
                        fontSize: titleFontSize,
                        fontFamily: 'Regular',
                        color: Colors.black,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Community Wallet')
                              .doc('wallet')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: Text('Loading'));
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Something went wrong'));
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final docSnap = snapshot.data!;
                            final map = docSnap.data() as Map<String, dynamic>?;
                            final int pts = (map != null && map['pts'] is num)
                                ? (map['pts'] as num).toInt()
                                : 0;
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: TextWidget(
                                text: AppConstants.formatNumberWithPeso(pts),
                                fontSize: balanceFontSize,
                                fontFamily: 'Bold',
                                color: primary,
                              ),
                            );
                          }),
                    ],
                  ),
                  SizedBox(height: isMobile ? 15.0 : 20.0),

                  // Data display - either table or cards based on screen size
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Slots')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return const Center(child: Text('Error'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: isMobile ? 30.0 : 50.0),
                            child: const Center(
                                child: CircularProgressIndicator(
                              color: Colors.black,
                            )),
                          );
                        }

                        final data = snapshot.requireData;

                        if (data.docs.isEmpty) {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: isMobile ? 30.0 : 50.0),
                            child: const Center(
                              child: Text('No slots found'),
                            ),
                          );
                        }

                        // For desktop and tablet, show the DataTable
                        if (isDesktop || isTablet) {
                          return DataTable(
                              columnSpacing: isTablet ? 15.0 : 30.0,
                              horizontalMargin: isTablet ? 10.0 : 20.0,
                              headingRowHeight: isTablet ? 50.0 : 56.0,
                              dataRowHeight: isTablet ? 45.0 : 56.0,
                              columns: [
                                DataColumn(
                                  label: TextWidget(
                                    text: 'Slot',
                                    fontSize: headerFontSize,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                                DataColumn(
                                  label: TextWidget(
                                    text: 'Name',
                                    fontSize: headerFontSize,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                                DataColumn(
                                  label: TextWidget(
                                    text: 'Points',
                                    fontSize: headerFontSize,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ],
                              rows: [
                                for (int i = 0; i < data.docs.length; i++)
                                  DataRow(cells: [
                                    DataCell(
                                      TextWidget(
                                        text: '${i + 1}',
                                        fontSize: dataFontSize,
                                      ),
                                    ),
                                    DataCell(
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(data.docs[i]['uid'])
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child: Text('Loading'));
                                            } else if (snapshot.hasError) {
                                              return const Center(
                                                  child: Text(
                                                      'Something went wrong'));
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            dynamic mydata = snapshot.data;
                                            return TextWidget(
                                              text: mydata['name'],
                                              fontSize: dataFontSize,
                                            );
                                          }),
                                    ),
                                    DataCell(
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(data.docs[i]['uid'])
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child: Text('Loading'));
                                            } else if (snapshot.hasError) {
                                              return const Center(
                                                  child: Text(
                                                      'Something went wrong'));
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            dynamic mydata = snapshot.data;
                                            return TextWidget(
                                              text:
                                                  '${mydata['pts'].toInt()} pts',
                                              fontSize: dataFontSize,
                                            );
                                          }),
                                    ),
                                  ])
                              ]);
                        }

                        // For mobile, show a card-based layout
                        return Column(
                          children: [
                            for (int i = 0; i < data.docs.length; i++)
                              _buildMobileSlotCard(
                                  i, data.docs[i], dataFontSize, isMobile)
                          ],
                        );
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileSlotCard(int index, DocumentSnapshot slotDoc,
      double fontSize, bool isSmallMobile) {
    final cardWidth = isSmallMobile ? double.infinity : null;
    final cardPadding = isSmallMobile ? 12.0 : 16.0;
    final spacing = isSmallMobile ? 8.0 : 12.0;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextWidget(
                  text: 'Slot ${index + 1}',
                  fontSize: fontSize,
                  fontFamily: 'Bold',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // User name
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(slotDoc['uid'])
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('Loading'));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                dynamic mydata = snapshot.data;
                return Row(
                  children: [
                    Icon(Icons.person, size: 16, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextWidget(
                        text: mydata['name'],
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                );
              }),

          SizedBox(height: spacing / 2),

          // Points
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(slotDoc['uid'])
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('Loading'));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                dynamic mydata = snapshot.data;
                return Row(
                  children: [
                    Icon(Icons.stars, size: 16, color: secondary),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: '${mydata['pts'].toInt()} pts',
                      fontSize: fontSize,
                      fontFamily: 'Bold',
                      color: primary,
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
