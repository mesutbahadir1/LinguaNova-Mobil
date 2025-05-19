import 'dart:math' as math;
import 'package:flutter/material.dart';

class EnhancedChatbotButton extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const EnhancedChatbotButton({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  State<EnhancedChatbotButton> createState() => _EnhancedChatbotButtonState();
}

class _EnhancedChatbotButtonState extends State<EnhancedChatbotButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedChatbotButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start animation when button becomes active
    if (widget.selectedIndex == widget.index && oldWidget.selectedIndex != widget.index) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.selectedIndex == widget.index;

    // Control animation based on selection state
    if (isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!isActive && _controller.isAnimating) {
      _controller.stop();
    }

    return TextButton(
      onPressed: () => widget.onIndexChanged(widget.index),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        // overlayColor özelliğini kaldırıyoruz
      ),
      child: Container(
        height: 60,
        width: 60,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Animated background particles when active
                if (isActive)
                  ...List.generate(
                    8,
                        (i) => Positioned(
                      top: 30 + 15 * math.sin(i * math.pi / 4 + _controller.value * math.pi),
                      left: 30 + 15 * math.cos(i * math.pi / 4 + _controller.value * math.pi),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Color(0xFF3D5CFF).withOpacity(0.6 - (i % 3) * 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                // Outer glow effect
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF3D5CFF).withOpacity(
                            isActive ? _glowAnimation.value : 0.15),
                        blurRadius: isActive ? 18 : 8,
                        spreadRadius: isActive ? 2 : 0,
                      ),
                    ],
                  ),
                ),

                // Inner pulsing circle
                if (isActive)
                  Container(
                    width: 44 * _scaleAnimation.value,
                    height: 44 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3D5CFF).withOpacity(0.12),
                    ),
                  ),

                // Main button with rotation effect
                Transform.rotate(
                  angle: isActive ? _rotationAnimation.value : 0,
                  child: Container(
                    padding: EdgeInsets.all(isActive ? 10 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5E7DFF),
                          Color(0xFF3D5CFF),
                          Color(0xFF2442E0),
                        ],
                      )
                          : null,
                      color: isActive ? null : Colors.transparent,
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withOpacity(0.8)
                            : Color(0xFF3D5CFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                        BoxShadow(
                          color: Color(0xFF3D5CFF).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 0,
                        )
                      ]
                          : null,
                    ),
                    child: Icon(
                      Icons.bubble_chart		,
                      color: (isActive
                          ? Colors.white
                          : Color(0xFF3D5CFF).withOpacity(0.8)),
                      size: 28,
                    ),
                  ),
                ),

                // Optional: Small dot indicator below
                if (isActive)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3D5CFF),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3D5CFF).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Use this as a wrapper for your buttons
class ChatbotNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const ChatbotNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3, // Adjust based on your actual number of buttons
            (index) => EnhancedChatbotButton(
          index: index,
          selectedIndex: selectedIndex,
          onIndexChanged: onIndexChanged,
        ),
      ),
    );
  }
}

// Implementation example:
// static Widget _buildChatbotButton(BuildContext context, int index, int selectedIndex, Function(int) onIndexChanged) {
//   return EnhancedChatbotButton(
//     index: index,
//     selectedIndex: selectedIndex,
//     onIndexChanged: onIndexChanged,
//   );
// }