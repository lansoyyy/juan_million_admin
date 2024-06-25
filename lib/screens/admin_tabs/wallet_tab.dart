import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/widgets/text_widget.dart';

import '../../utlis/colors.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 150,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: '150pts',
                    fontSize: 32,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: 'Company Income',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: 170,
              height: 150,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: '150pts',
                    fontSize: 32,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: 'Tech Support Income',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 150,
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.business,
                    size: 75,
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: 'Affiliates',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: 170,
              height: 150,
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 75,
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: 'Members',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
