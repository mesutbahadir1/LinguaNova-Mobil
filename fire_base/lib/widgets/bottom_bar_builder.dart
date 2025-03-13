import 'package:flutter/material.dart';

class BottomBarBuilder {
  static Widget buildBottomNavigationBar(BuildContext context, {
    required int selectedIndex,
    required Function(int) onIndexChanged,
  }) {
    return BottomAppBar(
      color: const Color.fromRGBO(31, 31, 57, 1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton(context, 0, selectedIndex, onIndexChanged, label: 'Home', icon: Icons.home),
          _buildButton(context, 1, selectedIndex, onIndexChanged, label: 'Article', icon: Icons.book),
          _buildButton(context, 2, selectedIndex, onIndexChanged, label: 'Progress', icon: Icons.bar_chart),
          _buildButton(context, 3, selectedIndex, onIndexChanged, label: 'Program', icon: Icons.school),
          _buildButton(context, 4, selectedIndex, onIndexChanged, label: 'Account', icon: Icons.person),
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
