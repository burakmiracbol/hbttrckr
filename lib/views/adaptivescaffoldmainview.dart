// Copyright (C) 2026  [Burak Miraç Bol]
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';


// olmayan propertyler : background color ,

class AdaptiveScaffoldMainView extends StatefulWidget {
  const AdaptiveScaffoldMainView({super.key});

  @override
  State<AdaptiveScaffoldMainView> createState() => _AdaptiveScaffoldMainViewState();
}

class _AdaptiveScaffoldMainViewState extends State<AdaptiveScaffoldMainView> {
  int _selectedTab = 0;
  int _transitionDuration = 50;
  TextStyle headerColor = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey[700],
  );



  late NavigationRailThemeData navRailTheme;
  late Widget trailingNavRail;
  late List<Widget> children;

  @override
  void initState() {
    super.initState();
    navRailTheme = NavigationRailThemeData(
      backgroundColor: Colors.grey[100],
      selectedIconTheme: IconThemeData(color: Colors.blue[700]),
      unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
      selectedLabelTextStyle: TextStyle(color: Colors.blue[700]),
      unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
    );



    trailingNavRail = Icon(Icons.logout);

    children = [
      Container(color: Colors.blue),
      Container(color: Colors.red),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the children to display within the body at different breakpoints.
    final List<Widget> children = <Widget>[
      for (int i = 0; i < 10; i++)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: const Color.fromARGB(255, 186, 35, 24),
            height: 400,
          ),
        )
    ];
    return AdaptiveScaffold(
      // An option to override the default transition duration.
      transitionDuration: Duration(milliseconds: _transitionDuration),
      // An option to override the default breakpoints used for small, medium,
      // mediumLarge, large, and extraLarge.
      smallBreakpoint: const Breakpoint(endWidth: 700),
      mediumBreakpoint: const Breakpoint(beginWidth: 700, endWidth: 1000),
      mediumLargeBreakpoint: const Breakpoint(beginWidth: 1000, endWidth: 1200),
      largeBreakpoint: const Breakpoint(beginWidth: 1200, endWidth: 1600),
      extraLargeBreakpoint: const Breakpoint(beginWidth: 1600),
      useDrawer: false,
      selectedIndex: _selectedTab,
      onSelectedIndexChange: (int index) {
        setState(() {
          _selectedTab = index;
        });
      },
      destinations: <CustomNavigationDestination>[
        CustomNavigationDestination(
          enabled: false,
          icon: Expanded(
            child: IconButton(
              style: IconButton.styleFrom(
                shape: StadiumBorder(),
                foregroundColor: _selectedTab == 0 ? Theme.of(context).colorScheme.secondary : Colors.grey,
              ),
              icon: Icon(Icons.checklist_outlined),
              onPressed: () => onItemTapped(0),
            ),
          ),
          selectedIcon: Icon(Icons.checklist),
          label: 'Habits',
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.add_outlined),
          selectedIcon: Icon(Icons.add),
          label: 'Add',
        ),
        CustomNavigationDestination(
          enabled: false,
          icon: Expanded(
            child: IconButton(
              style: IconButton.styleFrom(
                shape: StadiumBorder(),
                foregroundColor: _selectedTab == 2 ? Theme.of(context).colorScheme.secondary : Colors.grey,
              ),
              icon: Icon(Icons.bar_chart_outlined),
              onPressed: () => onItemTapped(2),
            ),
          ),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
      ],
      smallBody: (_) => ListView.builder(
        itemCount: children.length,
        itemBuilder: (_, int idx) => children[idx],
      ),
      body: (_) => GridView.count(crossAxisCount: 2, children: children),
      mediumLargeBody: (_) =>
          GridView.count(crossAxisCount: 3, children: children),
      largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
      extraLargeBody: (_) =>
          GridView.count(crossAxisCount: 5, children: children),

      // Define a default secondaryBody.
      // Override the default secondaryBody during the smallBreakpoint to be
      // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
      // overridden.
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      secondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 255, 0, 0),
      ),
      mediumLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 255, 100, 100),
      ),
      largeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 200, 100, 100),
      ),
      extraLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 158),
      ),
    );
  }
}