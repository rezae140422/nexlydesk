import 'package:flutter/material.dart';

/// Minimum size of the desktop main window (home page incl. ID/password card).
const Size kNexlyMainWindowMinSize = Size(720, 520);

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

/// Persian hint: how to connect directly by IP (no server needed).
class NexlyDirectIpHint extends StatelessWidget {
  const NexlyDirectIpHint({super.key});
  static const text =
      'اتصال مستقیم با IP (بدون نیاز به سرور): در دستگاه مقصد NexlyDesk را باز کنید و نشانی IP آن را (مثلاً 192.168.1.20) در کادر بالا بنویسید و «اتصال» را بزنید. دو دستگاه باید در یک شبکه باشند یا پورت 21118 دستگاه مقصد در دسترس باشد. «دسترسی مستقیم با IP» به‌طور پیش‌فرض روشن است.';
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: Theme.of(context).textTheme.bodySmall?.color)),
    );
  }
}
