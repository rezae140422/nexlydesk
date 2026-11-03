import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hbb/nexly/nexly_full_value.dart';

void main() {
  test('direct-IP mode when no rendezvous server is configured', () {
    expect(nexlyIsDirectIpMode(''), isTrue);
    expect(nexlyIsDirectIpMode('  '), isTrue);
    expect(nexlyIsDirectIpMode('hbbs.example.com'), isFalse);
  });

  testWidgets('green direct-ready status text', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: NexlyDirectReadyStatus())));
    final w = t.widget<Text>(find.byKey(const Key('nexly-direct-ready')));
    expect(w.data, 'آماده‌ی اتصال مستقیم');
    expect(w.style!.color, kNexlyDirectReadyColor);
  });

  testWidgets('IP input hint', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: NexlyIpInputHint())));
    expect(find.text('بدون سرور، آی‌پی دستگاه مقابل را وارد کنید (مثلاً 192.168.1.20)'), findsOneWidget);
  });

  testWidgets('local IPs shown in full, LTR, with copy buttons', (t) async {
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 180,
                child: NexlyLocalIps(
                    loader: () async => ['192.168.100.200', '10.0.0.5'])))));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byKey(const Key('nexly-copy-ip-192.168.100.200')), findsOneWidget);
    expect(find.byKey(const Key('nexly-copy-ip-10.0.0.5')), findsOneWidget);
    final st = t.widgetList<SelectableText>(find.byType(SelectableText)).map((e) => e.data).toList();
    expect(st, ['192.168.100.200', '10.0.0.5']);
  });
}
