import 'package:desktop_app/components/dashboard_content_container.dart';
import 'package:desktop_app/components/sidebar.dart';
import 'package:desktop_app/components/user_icon_dropdown.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Calculate sidebar width: 30% of viewport, min 320px
  double _calculateSidebarWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredWidth = screenWidth * 0.2;
    return desiredWidth < 320 ? 320 : desiredWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar: Fixed height, 30% width with min 320px
          Container(
            width: _calculateSidebarWidth(context),
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            child: const Sidebar(),
          ),
          // Main Content: Takes remaining space
          Expanded(
            child: Stack(
              children: [
                const DashboardContentContainer(),
                const UserIconDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
