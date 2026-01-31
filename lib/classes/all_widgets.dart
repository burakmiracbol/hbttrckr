import 'dart:ui';

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:yaru/widgets.dart' as yaru;
import 'package:flutter/widgets.dart';
import 'package:hbttrckr/providers/style_provider.dart';

import '../providers/scheme_provider.dart';
import '../services/theme_color_service.dart';

enum AppDesignMode { material, cupertino, liquid, fluent, macos, yaru }

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
            items: destinations
                .map(
                  (d) => fluent.PaneItem(
                    icon: d.icon,
                    title: Text(d.label),
                    body: const SizedBox.shrink(),
                  ),
                )
                .toList(),
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
              items: destinations
                  .map(
                    (d) => macos.SidebarItem(
                      leading: d.icon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
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
                destinations: destinations
                    .map(
                      (d) => material.NavigationRailDestination(
                        icon: d.icon,
                        label: Text(d.label),
                      ),
                    )
                    .toList(),
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
            items: destinations
                .map(
                  (d) => cupertino.BottomNavigationBarItem(
                    icon: d.icon,
                    label: d.label,
                  ),
                )
                .toList(),
          ),
          tabBuilder: (context, index) =>
              cupertino.CupertinoPageScaffold(child: body),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.spaceAround,
                      children: destinations.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var d = entry.value;
                        bool isSelected = currentIndex == idx;
                        return material.IconButton(
                          icon: d.icon,
                          color: isSelected
                              ? material.Colors.blue
                              : material.Colors.grey,
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
  final EdgeInsets padding;

  const PlatformButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    switch (context.read<StyleProvider>().current) {
      case AppDesignMode.cupertino:
        return cupertino.Padding(
          padding: padding,
          child: cupertino.CupertinoButton.filled(
            onPressed: onPressed,
            child: child,
          ),
        );
      case AppDesignMode.fluent:
        return cupertino.Padding(
          padding: padding,
          child: fluent.FilledButton(onPressed: onPressed, child: child),
        );
      case AppDesignMode.liquid:
        return cupertino.Padding(
          padding: padding,
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(borderRadius: 160),
            child: GlassGlow(
              child: material.ElevatedButton(
                style: material.ElevatedButton.styleFrom(
                  backgroundColor: material.Colors.transparent,
                ),
                onPressed: onPressed,
                child: child,
              ),
            ),
          ),
        );
      case AppDesignMode.material:
        return Padding(
          padding: padding,
          child: material.ElevatedButton(onPressed: onPressed, child: child),
        );
      case AppDesignMode.macos:
        return cupertino.Padding(
          padding: padding,
          child: macos.PushButton(
            onPressed: onPressed,
            controlSize: macos.ControlSize.regular,
            child: child,
          ),
        );
      case AppDesignMode.yaru:
        return Padding(
          padding: padding,
          child: yaru.YaruOptionButton(onPressed: onPressed, child: child),
        );
    }
  }
}

class PlatformTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const PlatformTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.read<StyleProvider>().current;
    switch (style) {
      case AppDesignMode.cupertino:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: cupertino.CupertinoTextField(
            controller: controller,
            placeholder: hintText,
          ),
        );
      case AppDesignMode.fluent:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: fluent.TextBox(
            controller: controller,
            placeholder: hintText,
          ),
        ); // fluent_ui
      case AppDesignMode.liquid:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(borderRadius: 64),
            child: material.TextField(
              controller: controller,
              style: TextStyle(color: material.Colors.white),
              decoration: material.InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: material.Colors.grey),
                border: material.OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                filled: false,
              ),
            ),
          ),
        );
      case AppDesignMode.macos:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: macos.MacosTextField(
            controller: controller,
            placeholder: hintText,
          ),
        );
      case AppDesignMode.yaru:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: yaru.YaruSearchField(controller: controller, hintText: hintText),
        );
      case AppDesignMode.material:
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: material.TextField(
            controller: controller,
            style: TextStyle(color: material.Colors.white),
            decoration: material.InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: material.Colors.grey),
              border: material.OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: material.Colors.grey[900],
            ),
          ),
        );
    }
  }
}

class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PlatformSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

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

class PlatformTitle extends StatelessWidget {
  final EdgeInsets padding;
  final String title;

  // TextStyle Parametreleri
  final bool inherit;
  final Color? color;
  final Color? backgroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final TextLeadingDistribution? leadingDistribution;
  final Locale? locale;
  final Paint? foreground;
  final Paint? background;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final List<FontVariation>? fontVariations;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final String? debugLabel;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final String? package;
  final TextOverflow? overflow;

  const PlatformTitle({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.title,
    this.inherit = true,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.leadingDistribution,
    this.locale,
    this.foreground,
    this.background,
    this.shadows,
    this.fontFeatures,
    this.fontVariations,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.debugLabel,
    this.fontFamily,
    this.fontFamilyFallback,
    this.package,
    this.overflow,
  });

  // Üçü de aynı parametreleri kabul ettiği için ortak bir stil üretici
  material.TextStyle _buildStyle() {
    return material.TextStyle(
      inherit: inherit,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.read<StyleProvider>().current;
    final commonStyle = _buildStyle();

    switch (mode) {
      case AppDesignMode.cupertino:
        return Padding(
          padding: padding,
          child: material.Text(title, style: commonStyle),
        );
      case AppDesignMode.fluent:
        return Padding(
          padding: padding,
          child: material.Text(title, style: commonStyle),
        );
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: const LiquidRoundedRectangle(borderRadius: 160),
          child: GlassGlow(
            child: Padding(
              padding: padding,
              child: material.Text(title, style: commonStyle),
            ),
          ),
        );
      case AppDesignMode.macos:
        return Padding(
          padding: padding,
          child: material.Text(title, style: commonStyle),
        );
      case AppDesignMode.yaru:
      return Padding(
        padding: padding,
        child: material.Text(title, style: commonStyle),
      );
      case AppDesignMode.material:
        return Padding(
          padding: padding,
          child: material.Text(title, style: commonStyle),
        );
    }
  }
}

class PlatformCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const PlatformCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    switch (context.read<StyleProvider>().current) {
      case AppDesignMode.cupertino:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cupertino.CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        );
      case AppDesignMode.fluent:
        return fluent.Card(
          // fluent_ui Card
          padding: padding,
          child: child,
        );
      case AppDesignMode.liquid:
        return LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 24),
          child: GlassGlow(
            child: Padding(padding: padding, child: child),
          ),
        );
      case AppDesignMode.macos:
        return material.Container(
          padding: padding,
          decoration: material.BoxDecoration(
            color: macos.MacosColors.controlBackgroundColor,
            borderRadius: material.BorderRadius.circular(8),
            border: material.Border.all(
              color: macos.MacosColors.windowFrameColor.withOpacity(0.1),
            ),
          ),
          child: child,
        );
      case AppDesignMode.yaru:
        return yaru.YaruSection(
          // yaru.dart ile gelen bölüm yapısı
          child: Padding(padding: padding, child: child),
        );
      case AppDesignMode.material:
        return material.Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: padding, child: child),
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
        return fluent.ListTile(
          // fluent_ui ListTile
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          onPressed: onTap,
        );
      case AppDesignMode.liquid:
        return cupertino.Padding(
          padding: const EdgeInsets.all(6.0),
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(borderRadius: 320),
            child: GlassGlow(
              child: material.Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(640),
                ),
                shadowColor: material.Colors.transparent,
                color: material.Colors.transparent,
                child: material.ListTile(
                  splashColor: null,
                  title: title,
                  subtitle: subtitle,
                  leading: leading,
                  trailing: trailing,
                  onTap: onTap,
                  tileColor:
                      material.Colors.transparent, // Camın arkasını kapatmasın
                ),
              ),
            ),
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
            backgroundColor: material.Colors.transparent,
            collapsedBackgroundColor: material.Colors.transparent,
            children: children,
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

Future<T?> showPlatformModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder, // builder'a geçtik
  String? title,
  bool isScrollControlled = false, // Boyut kontrolü
  bool useSafeArea = true,
  bool enableDrag = true,
  bool isDismissible = true,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
}) {
  final designMode = context.read<StyleProvider>().current;
  final scheme = context.read<SchemeProvider>();
  final themeMode = context.read<CurrentThemeMode>();
  final isDark = themeMode.isDarkMode;
  final m3 = colorSchemeFromMaterial(buildMaterialScheme(scheme, isDark));

  // Yükseklik limitini isScrollControlled'a göre ayarlıyoruz
  final screenHeight = MediaQuery.of(context).size.height;
  final boxConstraints = BoxConstraints(
    maxHeight: isScrollControlled ? screenHeight * 0.9 : screenHeight * 0.6,
  );

  switch (designMode) {
    case AppDesignMode.macos:
      return macos.showMacosSheet<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => macos.MacosSheet(
          child: material.Material(
            color: backgroundColor ?? material.Colors.transparent,
            child: SafeArea(
              bottom: useSafeArea,
              child: ConstrainedBox(
                constraints: boxConstraints,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          title,
                          style: macos.MacosTheme.of(
                            context,
                          ).typography.headline,
                        ),
                      ),
                    Flexible(child: builder(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

    case AppDesignMode.fluent:
      return fluent.showDialog<T>(
        // fluent.showDialog olarak düzelttim
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => fluent.ContentDialog(
          constraints: boxConstraints.copyWith(maxWidth: 400),
          title: title != null ? Text(title) : null,
          content: builder(context),
          actions: [
            fluent.Button(
              child: const Text('Kapat'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

    case AppDesignMode.cupertino:
      return cupertino.showCupertinoModalPopup<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => SafeArea(
          bottom: useSafeArea,
          child: cupertino.CupertinoActionSheet(
            title: title != null ? Text(title) : null,
            message: ConstrainedBox(
              constraints: boxConstraints,
              child: material.Material(
                color: material.Colors.transparent,
                child: builder(context),
              ),
            ),
            cancelButton: cupertino.CupertinoActionSheetAction(
              child: const Text('Kapat'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      );

    case AppDesignMode.liquid:
      return material.showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        backgroundColor: material.Colors.transparent,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        builder: (context) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(64)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(64),
                ),
                border: Border.all(
                  color: material.Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: material.Container(
                padding: const EdgeInsets.all(20),
                decoration: material.BoxDecoration(
                  color: backgroundColor ?? m3.surface.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: LiquidGlassLayer(
                  child: GlassGlowLayer(child: builder(context)),
                ),
              ),
            ),
          ),
        ),
      );

    default: // Material ve Yaru aynı sheeti kullanıcaklar şimdilik
      return material.showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        showDragHandle: enableDrag,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        backgroundColor: backgroundColor ?? m3.surface,
        elevation: elevation,
        shape:
            shape ??
            const material.RoundedRectangleBorder(
              borderRadius: material.BorderRadius.vertical(
                top: material.Radius.circular(24),
              ),
            ),
        builder: (context) => builder(context),
      );
  }
}
