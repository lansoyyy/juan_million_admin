import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/admin_tabs/wallets/business_wallets.dart';
import 'package:juan_million/screens/admin_tabs/wallets/company_wallet.dart';
import 'package:juan_million/screens/admin_tabs/wallets/it_wallet.dart';
import 'package:juan_million/screens/admin_tabs/wallets/member_wallets.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/widgets/text_widget.dart';

import '../../utlis/colors.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;
        
        // Calculate container dimensions based on screen size
        final containerWidth = isMobile ? constraints.maxWidth * 0.4 : 170.0;
        final containerHeight = isMobile ? 120.0 : 150.0;
        final fontSize = isMobile ? 24.0 : 32.0;
        final labelFontSize = isMobile ? 10.0 : 12.0;
        final iconSize = isMobile ? 50.0 : 75.0;
        final spacing = isMobile ? 10.0 : 20.0;
        
        // Calculate padding based on screen size
        final horizontalPadding = isMobile ? 16.0 : isTablet ? 24.0 : 32.0;
        final verticalPadding = isMobile ? 16.0 : isTablet ? 24.0 : 40.0;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First row of wallet cards
              if (isDesktop || isTablet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCompanyWalletCard(containerWidth, containerHeight, fontSize, labelFontSize, context),
                    _buildITWalletCard(containerWidth, containerHeight, fontSize, labelFontSize, context),
                  ],
                )
              else
                Column(
                  children: [
                    _buildCompanyWalletCard(containerWidth, containerHeight, fontSize, labelFontSize, context),
                    SizedBox(height: spacing),
                    _buildITWalletCard(containerWidth, containerHeight, fontSize, labelFontSize, context),
                  ],
                ),
              
              SizedBox(height: spacing),
              
              // Second row of wallet cards
              if (isDesktop || isTablet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBusinessWalletCard(containerWidth, containerHeight, iconSize, labelFontSize, context),
                    _buildMemberWalletCard(containerWidth, containerHeight, iconSize, labelFontSize, context),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBusinessWalletCard(containerWidth, containerHeight, iconSize, labelFontSize, context),
                    SizedBox(height: spacing),
                    _buildMemberWalletCard(containerWidth, containerHeight, iconSize, labelFontSize, context),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyWalletCard(double width, double height, double fontSize, double labelFontSize, BuildContext context) {
    return Builder(
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Community Wallet')
              .doc('business')
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic walletdata = snapshot.data;
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CompanyWallet(
                          total: walletdata['pts'],
                        )));
              },
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: AppConstants.formatNumberWithPeso(walletdata['pts']),
                      fontSize: fontSize,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    TextWidget(
                      text: 'Company Income',
                      fontSize: labelFontSize,
                      fontFamily: 'Regular',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildITWalletCard(double width, double height, double fontSize, double labelFontSize, BuildContext context) {
    return Builder(
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Community Wallet')
              .doc('it')
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic walletdata = snapshot.data;
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ITWallet(
                          total: walletdata['pts'],
                        )));
              },
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: AppConstants.formatNumberWithPeso(walletdata['pts']),
                      fontSize: fontSize,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    TextWidget(
                      text: 'Tech Support Income',
                      fontSize: labelFontSize,
                      fontFamily: 'Regular',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildBusinessWalletCard(double width, double height, double iconSize, double labelFontSize, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const BusinessWallets()));
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: iconSize,
              color: Colors.white,
            ),
            TextWidget(
              text: 'Affiliates',
              fontSize: labelFontSize,
              fontFamily: 'Regular',
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberWalletCard(double width, double height, double iconSize, double labelFontSize, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const MemberWallets()));
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: iconSize,
              color: Colors.white,
            ),
            TextWidget(
              text: 'Members',
              fontSize: labelFontSize,
              fontFamily: 'Regular',
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
