import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBarBuilder {
  static Widget buildBottomNavigationBar(BuildContext context, {
    required int selectedIndex,
    required Function(int) onIndexChanged,
  }) {
    // Function to ensure a clean navigation between screens
    Future<void> _handleNavigation(int index) async {
      // Skip if already on the same tab
      if (index == selectedIndex) return;
      
      // Store current selection
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Clear any caches to force refresh
      // Force a refresh for all content views
      await prefs.remove('lastContentRefresh');
      
      // Store the new tab index
      await prefs.setInt('lastContentTab', index);
      
      // Immediately trigger navigation callback
      onIndexChanged(index);
      
      // Force a refresh by removing all cached content for the new view
      if (index >= 1 && index <= 3) {
        // İçerik sayfalarının yükleme zamanlarını sıfırla
        await prefs.remove('lastSuccessfulFetch_type$index');
        print('BottomNav: Forced refresh for content type $index');
      }
    }
    
    return BottomAppBar(
      color: const Color.fromRGBO(31, 31, 57, 1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton(context, 0, selectedIndex, _handleNavigation, label: 'Home', icon: Icons.home),
          _buildButton(context, 1, selectedIndex, _handleNavigation, label: 'Article', icon: Icons.book),
          _buildButton(context, 2, selectedIndex, _handleNavigation, label: 'Audio', icon: Icons.headphones),
          _buildButton(context, 3, selectedIndex, _handleNavigation, label: 'Video', icon: Icons.video_library),
          _buildButton(context, 4, selectedIndex, _handleNavigation, label: 'Account', icon: Icons.person),
        ],
      ),
    );
  }

  static Widget _buildButton(
      BuildContext context,
      int index,
      int selectedIndex,
      Function(int) onIndexChanged,
      {required String label, IconData? icon}
      ) {
    bool isActive = selectedIndex == index;

    return TextButton(
      onPressed: () => onIndexChanged(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: (isActive ? const Color(0xFF3D5CFF) : Colors.grey),
              size: 20,
            ),
          SizedBox(height: icon != null ? 5 : 30),
          Align(
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (isActive ? const Color(0xFF3D5CFF) : Colors.grey),
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
