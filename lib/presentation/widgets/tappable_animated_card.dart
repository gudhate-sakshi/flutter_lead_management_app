import 'package:flutter/material.dart';

class TappableAnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color baseColor;

  const TappableAnimatedCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.baseColor,
  });

  @override
  State<TappableAnimatedCard> createState() => _TappableAnimatedCardState();
}

class _TappableAnimatedCardState extends State<TappableAnimatedCard> {
  // State variable to track if the card is pressed
  bool _isPressed = false;

  // FIX: TapDownDetails is now correctly recognized due to the import
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  // FIX: TapUpDetails is now correctly recognized
  void _onTapUp(TapUpDetails details) {
    // Slight delay before resetting the state to show the effect
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap(); // Execute the original tap action
      }
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the scale and color based on the pressed state
    const double scaleFactor = 0.98; // Shrink by 2%
    // Slightly adjust the color to simulate depth/press
    final Color pressedColor = widget.baseColor.withOpacity(0.8);
    final Color finalColor = _isPressed ? pressedColor : widget.baseColor;
    final double finalScale = _isPressed ? scaleFactor : 1.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent, // Ensure taps are registered easily
      child: AnimatedScale( // Handles the scale animation
        scale: finalScale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container( // Used to apply the animated background color
          decoration: BoxDecoration(
            color: finalColor,
            borderRadius: BorderRadius.circular(16), // Match your Card's styling
          ),
          // We wrap the child in a Padding to match the internal padding of a standard Card
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
            child: widget.child,
          ),
        ),
      ),
    );
  }
}