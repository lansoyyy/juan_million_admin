import 'package:flutter/material.dart';
import 'package:juan_million/screens/admin_tabs/community_tab.dart';
import 'package:juan_million/screens/admin_tabs/wallet_tab.dart';
import 'package:juan_million/utlis/colors.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  var _currentIndex = 0;

  List tabs = [
    const WalletTab(),
    const CommunityTab(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;
        
        if (isDesktop) {
          // Use navigation rail for desktop
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  extended: constraints.maxWidth >= 1200,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.wallet),
                      selectedIcon: Icon(Icons.wallet, color: Colors.white),
                      label: Text('Cash Wallet'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.groups_2_outlined),
                      selectedIcon: Icon(Icons.groups_2_outlined, color: Colors.white),
                      label: Text('Community Wallet'),
                    ),
                  ],
                  backgroundColor: blue,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Bold',
                  ),
                  unselectedIconTheme: const IconThemeData(color: Colors.black),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Regular',
                  ),
                  labelType: constraints.maxWidth >= 1200
                    ? null
                    : NavigationRailLabelType.selected,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: tabs[_currentIndex],
                ),
              ],
            ),
          );
        } else if (isTablet) {
          // Use navigation rail with extended = false for tablet
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  extended: false,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.wallet),
                      selectedIcon: Icon(Icons.wallet, color: Colors.white),
                      label: Text('Cash Wallet'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.groups_2_outlined),
                      selectedIcon: Icon(Icons.groups_2_outlined, color: Colors.white),
                      label: Text('Community Wallet'),
                    ),
                  ],
                  backgroundColor: blue,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Bold',
                  ),
                  unselectedIconTheme: const IconThemeData(color: Colors.black),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Regular',
                  ),
                  labelType: NavigationRailLabelType.selected,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: tabs[_currentIndex],
                ),
              ],
            ),
          );
        } else {
          // Use bottom navigation bar for mobile
          return Scaffold(
            body: tabs[_currentIndex],
            bottomNavigationBar: SalomonBottomBar(
              backgroundColor: blue,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                /// Home
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.wallet,
                    color: _currentIndex == 0 ? Colors.white : Colors.black,
                  ),
                  title: const Text(
                    "Cash Wallet",
                    style: TextStyle(fontFamily: 'Bold'),
                  ),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.groups_2_outlined),
                  title: const Text(
                    "Community Wallet",
                    style: TextStyle(fontFamily: 'Bold'),
                  ),
                  selectedColor: Colors.white,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
