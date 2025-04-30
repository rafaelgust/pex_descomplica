import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ModelButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final AlignmentGeometry alignment;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ModelButton({
    super.key,
    this.width = double.infinity,
    this.height = 55.0,
    required this.onPressed,
    required this.isLoading,
    required this.text,

    this.alignment = Alignment.center,

    this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => onPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
            foregroundColor: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child:
              isLoading
                  ? SpinKitThreeBounce(color: foregroundColor, size: 24.0)
                  : Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
        ),
      ),
    );
  }
}
