import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import 'modern_sidebar.dart';

Sidebar macosUISidebar({
required List<SidebarDestination> items,
required int selectedIndex,
required Function(int) onItemSelected,
double width = 200,
}){
  return Sidebar(
    minWidth: width,
    maxWidth: width,

    builder: (context, scrollController) {
      return SidebarItems(
        currentIndex: selectedIndex,
        scrollController: scrollController,
        itemSize: SidebarItemSize.large,
        onChanged: (index) {
          onItemSelected(index);
        },
        items: items.map((destination) {
          return SidebarItem(
            label: Text(destination.label),
            leading: MacosIcon(
              selectedIndex == items.indexOf(destination)
                  ? destination.selectedIcon
                  : destination.icon,
            ),
          );
        }).toList(),
      );
    },
  );
}