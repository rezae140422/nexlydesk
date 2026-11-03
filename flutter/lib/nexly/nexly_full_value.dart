import 'package:flutter/material.dart';

/// Always shows the full value (ID / password): LTR, single line, auto-shrinks.
class NexlyFullValue extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const NexlyFullValue(this.text, {super.key, this.style});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SelectableText(text, style: style, maxLines: 1),
      ),
    );
  }
}
