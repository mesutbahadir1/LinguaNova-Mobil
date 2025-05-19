import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot_button.dart'; // EnhancedChatbotButton sınıfının bulunduğu dosya

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
      // elevation: 0, // İsteğe bağlı: Gölgeyi kaldırmak veya ayarlamak için
      // shape: CircularNotchedRectangle(), // Eğer FAB ile kullanılıyorsa
      padding: EdgeInsets.zero, // BottomAppBar'ın iç padding'ini sıfırlamak için eklendi
      child: SizedBox( // BottomAppBar'ın yüksekliğini kontrol etmek için SizedBox eklendi
        height: 65, // İstediğiniz yüksekliği ayarlayabilirsiniz, butonların sığması için yeterli olmalı
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildButton(
                context, 0, selectedIndex, _handleNavigation, label: 'Home',
                icon: Icons.home_outlined), // Outlined ikonlar daha modern durabilir
            _buildButton(
                context, 1, selectedIndex, _handleNavigation, label: 'Article',
                icon: Icons.article_outlined), // Outlined ikon

            // Chatbot butonu için _buildChatbotButton metodunu çağırıyoruz
            _buildChatbotButton(context, 4, selectedIndex, _handleNavigation),

            _buildButton(
                context, 2, selectedIndex, _handleNavigation, label: 'Audio',
                icon: Icons.headphones_outlined), // Outlined ikon
            _buildButton(
                context, 3, selectedIndex, _handleNavigation, label: 'Video',
                icon: Icons.video_library_outlined), // Outlined ikon
          ],
        ),
      ),
    );
  }

  static Widget _buildButton(BuildContext context,
      int index,
      int selectedIndex,
      Function(int) onIndexChanged,
      {required String label, IconData? icon}) {
    bool isActive = selectedIndex == index;
    const Color activeColor = Color(0xFF3D5CFF);
    // const Color activeColor = Color(0xFF89CFF0); // Baby Blue
    // const Color activeColor = Color(0xFF98FB98); // Pale Green
    const Color inactiveColor = Colors.grey; // Veya Color(0xFF8E8E93) iOS stili gri

    return Expanded( // Butonların eşit yer kaplaması için Expanded eklendi
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 4), // Dikey padding ayarı
          // splashColor: activeColor.withOpacity(0.1), // Dokunma efekti rengi
          // highlightColor: activeColor.withOpacity(0.05), // Basılı tutma efekti rengi
        ),
        onPressed: () => onIndexChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlanmasını sağlar
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22, // İkon boyutunu biraz artırdık
              ),
            SizedBox(height: icon != null ? 4 : 0), // İkon varsa boşluk, yoksa boşluk yok
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11, // Yazı boyutunu biraz artırdık
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, // Aktifken biraz daha kalın
              ),
              overflow: TextOverflow.ellipsis, // Uzun etiketler için
            ),
          ],
        ),
      ),
    );
  }

  // Bu metot, EnhancedChatbotButton sınıfındaki statik _buildChatbotButton metodunu çağırır.
  static Widget _buildChatbotButton(BuildContext context,
      int index,
      int selectedIndex,
      Function(int) onIndexChanged) {
    // Chatbot butonunu diğer butonlarla aynı hizada tutmak için bir Container içine alıyoruz
    return Container(
      width: 60, // Butonun genişliği
      child: EnhancedChatbotButton(
        index: index,
        selectedIndex: selectedIndex,
        onIndexChanged: onIndexChanged,
      ),
    );
  }
}
