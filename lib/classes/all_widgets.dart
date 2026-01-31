import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:yaru/widgets.dart'as yaru;
import 'package:flutter/widgets.dart';
import 'package:hbttrckr/providers/style_provider.dart';

enum AppDesignMode {
  material,
  cupertino,
  liquid,
  fluent,
  macos,
  yaru
}

class UniversalScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onIndexChanged;
  final AppDesignMode mode;
  final List<material.NavigationDestination> destinations;

  const UniversalScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.mode,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
    // 1. FLUENT (Windows Stili - Yandan Menü)
      case AppDesignMode.fluent:
        return fluent.NavigationView(
          pane: fluent.NavigationPane(
            selected: currentIndex,
            onChanged: onIndexChanged,
            displayMode: fluent.PaneDisplayMode.auto,
            items: destinations.map((d) => fluent.PaneItem(
              icon: d.icon,
              title: Text(d.label),
              body: const SizedBox.shrink(),
            )).toList(),
          ),
          content: body,
        );

    // 2. MACOS (macOS Stili - Sidebar)
      case AppDesignMode.macos:
        return macos.MacosWindow(
          sidebar: macos.Sidebar(
            builder: (context, scrollController) => macos.SidebarItems(
              currentIndex: currentIndex,
              onChanged: onIndexChanged,
              items: destinations.map((d) => macos.SidebarItem(
                leading: d.icon,
                label: Text(d.label),
              )).toList(),
            ),
            minWidth: 200,
          ),
          child: body,
        );

    // 3. YARU (Linux/Ubuntu Stili)
      case AppDesignMode.yaru:
        return material.Scaffold(
          body: Row(
            children: [
              material.NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: onIndexChanged,
                labelType: material.NavigationRailLabelType.all,
                destinations: destinations.map((d) => material.NavigationRailDestination(
                  icon: d.icon,
                  label: Text(d.label),
                )).toList(),
              ),
              const material.VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        );

    // 4. CUPERTINO (iOS Stili - Alt Tab)
      case AppDesignMode.cupertino:
        return cupertino.CupertinoTabScaffold(
          tabBar: cupertino.CupertinoTabBar(
            currentIndex: currentIndex,
            onTap: onIndexChanged,
            items: destinations.map((d) => cupertino.BottomNavigationBarItem(
              icon: d.icon,
              label: d.label,
            )).toList(),
          ),
          tabBuilder: (context, index) => cupertino.CupertinoPageScaffold(child: body),
        );

    // 5. LIQUID (Senin Özel Tasarımın - Stack & Floating)
      case AppDesignMode.liquid:
        return material.Scaffold(
          body: Stack(
            children: [
              body,
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: LiquidGlass(
                  shape: LiquidRoundedRectangle(borderRadius: 25),
                  child: material.Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.spaceAround,
                      children: destinations.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var d = entry.value;
                        bool isSelected = currentIndex == idx;
                        return material.IconButton(
                          icon: d.icon,
                          color: isSelected ? material.Colors.blue : material.Colors.grey,
                          onPressed: () => onIndexChanged(idx),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    // 6. MATERIAL (Standart Android Stili)
      case AppDesignMode.material:
        return material.Scaffold(
          body: body,
          bottomNavigationBar: material.NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            destinations: destinations,
          ),
        );
    }
  }
}


class PlatformButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const PlatformButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    switch (context.read<StyleProvider>().current) {
      case AppDesignMode.cupertino:
        return cupertino.CupertinoButton.filled(onPressed: onPressed, child: child);
      case AppDesignMode.fluent:
        return fluent.FilledButton(onPressed: onPressed, child: child);
      case AppDesignMode.liquid:
        return LiquidGlass(shape: LiquidRoundedRectangle(borderRadius: 160),
        child: material.ElevatedButton(onPressed: onPressed, child: child));
      case AppDesignMode.material:
        return material.ElevatedButton(onPressed: onPressed, child: child);
      case AppDesignMode.macos:
        return macos.PushButton(onPressed: onPressed, controlSize: macos.ControlSize.regular, child: child);
      case AppDesignMode.yaru:
        return yaru.YaruOptionButton(onPressed: onPressed, child: child);
    }
  }
}

class PlatformTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const PlatformTextField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final style = context.read<StyleProvider>().current;
    switch (style) {
      case AppDesignMode.cupertino:
        return cupertino.CupertinoTextField(controller: controller, placeholder: hintText);
      case AppDesignMode.fluent:
        return fluent.TextBox(controller: controller, placeholder: hintText); // fluent_ui
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 12),
          child: material.TextField(controller: controller, decoration: material.InputDecoration(hintText: hintText, border: material.InputBorder.none)),
        );
      case AppDesignMode.macos:
        return macos.MacosTextField(controller: controller, placeholder: hintText);
      case AppDesignMode.yaru:
        return yaru.YaruSearchField(controller: controller, hintText: hintText);
      case AppDesignMode.material:
        return material.TextField(controller: controller, decoration: material.InputDecoration(hintText: hintText));
    }
  }
}

class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PlatformSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final style = context.read<StyleProvider>().current;
    switch (style) {
      case AppDesignMode.cupertino:
        return cupertino.CupertinoSwitch(value: value, onChanged: onChanged);
      case AppDesignMode.fluent:
        return fluent.ToggleSwitch(checked: value, onChanged: onChanged);
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 20),
          child: material.Switch(value: value, onChanged: onChanged),
        );
      case AppDesignMode.macos:
        return macos.MacosSwitch(value: value, onChanged: onChanged);
      case AppDesignMode.yaru:
        return yaru.YaruSwitch(value: value, onChanged: onChanged);
      case AppDesignMode.material:
        return material.Switch(value: value, onChanged: onChanged);
    }
  }
}

class PlatformCard extends StatelessWidget {
  final Widget child;
  final double padding;

  const PlatformCard({super.key, required this.child, this.padding = 12.0});

  @override
  Widget build(BuildContext context) {
    switch (context.read<StyleProvider>().current) {
      case AppDesignMode.cupertino:
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: cupertino.CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        );
      case AppDesignMode.fluent:
        return fluent.Card( // fluent_ui Card
          padding: EdgeInsets.all(padding),
          child: child,
        );
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 24),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        );
      case AppDesignMode.macos:
        return material.Container(
          padding: material.EdgeInsets.all(padding),
          decoration: material.BoxDecoration(
            color: macos.MacosColors.controlBackgroundColor,
            borderRadius: material.BorderRadius.circular(8),
            border: material.Border.all(color: macos.MacosColors.windowFrameColor.withOpacity(0.1)),
          ),
          child: child,
        );
      case AppDesignMode.yaru:
        return yaru.YaruSection( // yaru.dart ile gelen bölüm yapısı
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        );
      case AppDesignMode.material:
        return material.Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        );
    }
  }
}

class PlatformListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;

  const PlatformListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (context.read<StyleProvider>().current) {
      case AppDesignMode.cupertino:
        return cupertino.CupertinoListTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing ?? const cupertino.CupertinoListTileChevron(),
          onTap: onTap,
        );
      case AppDesignMode.fluent:
        return fluent.ListTile( // fluent_ui ListTile
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          onPressed: onTap,
        );
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 16),
          child: material.ListTile(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            onTap: onTap,
            tileColor: material.Colors.transparent, // Camın arkasını kapatmasın
          ),
        );
      case AppDesignMode.macos:
        return macos.MacosListTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          onClick: onTap,
        );
      case AppDesignMode.yaru:
        return material.InkWell(
          onTap: onTap,
          child: yaru.YaruTile(
            title: title,
            leading: leading,
            trailing: trailing,
          ),
        );
      case AppDesignMode.material:
        return material.ListTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          onTap: onTap,
        );
    }
  }
}

class PlatformExpansionTile extends StatelessWidget {
  final Widget title;
  final List<Widget> children;
  final Widget? leading;

  const PlatformExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final mode = context.read<StyleProvider>().current;

    switch (mode) {
      case AppDesignMode.fluent:
        return fluent.Expander(
          header: title,
          content: material.Column(children: children),
        );

      case AppDesignMode.macos:
        return macos.MacosTheme(
          data: macos.MacosTheme.of(context),
          child: material.ExpansionTile(
            title: title,
            leading: leading,
            shape: const material.Border(),
            children: children,
          ),
        );

      case AppDesignMode.cupertino:
      // iOS'ta ExpansionTile yoktur, genelde Section içine liste olarak dizilir
        return cupertino.CupertinoListSection.insetGrouped(
          header: title,
          children: children,
        );

      case AppDesignMode.yaru:
      // Yaru'da genişleyen yapılar için YaruExpansionPanel veya standart kullanılır
        return material.ExpansionTile(
          title: title,
          leading: leading,
          children: children,
          // Yaru stilini korumak için renkleri Material üzerinden geçer
        );

      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 16),
          child: material.ExpansionTile(
            title: title,
            leading: leading,
            children: children,
            backgroundColor: material.Colors.transparent,
            collapsedBackgroundColor: material.Colors.transparent,
          ),
        );

      case AppDesignMode.material:
        return material.ExpansionTile(
          title: title,
          leading: leading,
          children: children,
        );
    }
  }
}


