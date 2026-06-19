import 'package:flutter/cupertino.dart';

/// Cupertino-style linear progress indicator
/// Used throughout Umma app for iOS-native feel
class CupertinoProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const CupertinoProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
