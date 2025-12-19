import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide IconButton;

class NavigationRailMain extends StatefulWidget {
  const NavigationRailMain({super.key});

  @override
  State<NavigationRailMain> createState() => _NavigationRailMainState();
}

class _NavigationRailMainState extends State<NavigationRailMain> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      contentShape: StadiumBorder(),
      content: FluentTheme(
        data: FluentThemeData(
          navigationPaneTheme: NavigationPaneThemeData(
            backgroundColor: Colors.grey[200],

          ),
        ),
        child: Scaffold(
          body: Center(
            child: Text('Navigation Rail Example Content'),
          ),
        ),
      ),

      appBar: NavigationAppBar(
        title: Text('Navigation Rail Example'),
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          color: Colors.blue,
        )
      ),
    );
  }
}
