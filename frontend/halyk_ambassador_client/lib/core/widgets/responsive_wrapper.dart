import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 420) {
          // Mobile layout - full width
          return child;
        } else {
          // Desktop/tablet layout - center content with 394px width
          return Container(
            color: backgroundColor ?? const Color(0xFFF5F5F5),
            child: Center(
              child: Container(
                width: 394,
                decoration: const BoxDecoration(color: Colors.white),
                child: child,
              ),
            ),
          );
        }
      },
    );
  }
}
