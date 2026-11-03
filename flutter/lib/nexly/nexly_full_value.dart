import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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


/// Green status text shown instead of the rendezvous status in direct-IP mode.
const String kNexlyDirectReadyText = 'آماده‌ی اتصال مستقیم';
const Color kNexlyDirectReadyColor = Color.fromARGB(255, 50, 190, 166);

/// Short hint under the remote ID field.
const String kNexlyIpInputHintText =
    'بدون سرور، آی‌پی دستگاه مقابل را وارد کنید (مثلاً 192.168.1.20)';

/// Direct-IP mode = no rendezvous server configured by the user.
bool nexlyIsDirectIpMode(String customRendezvousServer) =>
    customRendezvousServer.trim().isEmpty;

final RegExp _virtualIf = RegExp(
    r'(vEthernet|virtualbox|vmware|vmnet|vbox|docker|br-|veth|hyper-v|loopback|'
    r'tun|tap|utun|wg|zerotier|tailscale|npcap|pseudo|isatap|teredo|dummy|virbr)',
    caseSensitive: false);

/// Local IPv4 addresses of physical adapters (best effort).
Future<List<String>> nexlyLocalIpv4() async {
  try {
    final ifs = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLoopback: false);
    final out = <String>[];
    for (final i in ifs) {
      if (_virtualIf.hasMatch(i.name)) continue;
      for (final a in i.addresses) {
        final ip = a.address;
        if (ip.startsWith('127.') || ip.startsWith('169.254.')) continue;
        if (!out.contains(ip)) out.add(ip);
      }
    }
    return out;
  } catch (_) {
    return [];
  }
}

class NexlyDirectReadyStatus extends StatelessWidget {
  final double fontSize;
  const NexlyDirectReadyStatus({super.key, this.fontSize = 14});
  @override
  Widget build(BuildContext context) => Text(kNexlyDirectReadyText,
      key: const Key('nexly-direct-ready'),
      textDirection: TextDirection.rtl,
      style: TextStyle(
          fontSize: fontSize,
          color: kNexlyDirectReadyColor,
          fontWeight: FontWeight.bold));
}

class NexlyIpInputHint extends StatelessWidget {
  const NexlyIpInputHint({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Text(kNexlyIpInputHintText,
          key: const Key('nexly-ip-input-hint'),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary)));
}

/// "IP of this device" — large LTR value(s) with a copy button.
class NexlyLocalIps extends StatefulWidget {
  final double fontSize;
  final Future<List<String>> Function()? loader;
  const NexlyLocalIps({super.key, this.fontSize = 18, this.loader});
  @override
  State<NexlyLocalIps> createState() => _NexlyLocalIpsState();
}

class _NexlyLocalIpsState extends State<NexlyLocalIps> {
  List<String> _ips = const [];
  @override
  void initState() {
    super.initState();
    (widget.loader ?? nexlyLocalIpv4)().then((v) {
      if (mounted) setState(() => _ips = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = Text('آی‌پی این دستگاه (IP)',
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600));
    final rows = _ips.isEmpty
        ? [Text('—', style: TextStyle(fontSize: widget.fontSize))]
        : _ips
            .map((ip) => Row(children: [
                  Expanded(
                      child: NexlyFullValue(ip,
                          style: TextStyle(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.bold))),
                  IconButton(
                      key: Key('nexly-copy-ip-$ip'),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy',
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: ip))),
                ]))
            .toList();
    return Column(
        key: const Key('nexly-local-ips'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [label, ...rows]);
  }
}
