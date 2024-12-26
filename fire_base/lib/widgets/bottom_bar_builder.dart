import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../ui/views/knowledge/knowledge_screen.dart';

class BottomBarBuilder {
  static int _selectedIndex = 0;

  static Widget buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromRGBO(31, 31, 57, 1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton(context, 0, label: 'Home', icon: Icons.home),
          _buildButton(context, 1, label: 'Knowledge', icon: Icons.book),
          _buildButton(context, 2, label: 'Progress', icon: Icons.bar_chart),
          _buildButton(context, 3, label: 'Program', icon: Icons.school),
          _buildButton(context, 4, label: 'Account', icon: Icons.person),
        ],
      ),
    );
  }

  static Widget _buildButton(BuildContext context, int index,
      {required String label, IconData? icon}) {
    bool isActive = _selectedIndex == index;

    return TextButton(
      onPressed: () {
        _selectedIndex = index;

        // Knowledge button için özel işlem
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KnowledgeScreen()),
          );
        } else {
          // Diğer butonlar için yeniden çizim
          (context as Element).markNeedsBuild();
        }
      },
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

  static Widget buildFloatingActionButton(BuildContext context) {
    bool isActive = _selectedIndex == 2;

    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {
        _selectedIndex = 2;
        (context as Element).markNeedsBuild(); // Yeniden çizim için güncelle
      },
      elevation: 0,

    );
  }
}

