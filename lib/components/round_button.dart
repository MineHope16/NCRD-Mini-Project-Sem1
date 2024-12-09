import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final Color color; // New parameter for button color
  final Color textColor; // New parameter for text color

  const RoundButton({
    super.key,
    required this.title,
    required this.onPress,
    this.color = Colors.pink, // Default color is pink
    this.textColor = Colors.white, // Default text color is white
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0), // Changed from 10 to 30 for a more rounded look
      color: color,
      child: MaterialButton(
        minWidth: double.infinity,
        height: 50,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
