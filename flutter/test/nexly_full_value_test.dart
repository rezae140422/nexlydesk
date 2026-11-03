import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hbb/nexly/nexly_full_value.dart';

void main() {
  for (final width in [90.0, 140.0, 220.0]) {
    for (final id in ['123456789', '1234567890', '1 234 567 890']) {
      testWidgets('full ID "$id" at width $width in RTL, no overflow',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: NexlyFullValue(id,
                      style: const TextStyle(
                          fontSize: 30, letterSpacing: 2)),
                ),
              ),
            ),
          ),
        ));
        expect(tester.takeException(), isNull);
        final st = tester.widget<SelectableText>(find.byType(SelectableText));
        expect(st.data, id); // full text, not truncated
        final box = tester.getSize(find.byType(NexlyFullValue));
        expect(box.width <= width + 0.01, isTrue);
        final dir = tester.widget<Directionality>(find
            .ancestor(
                of: find.byType(FittedBox), matching: find.byType(Directionality))
            .first);
        expect(dir.textDirection, TextDirection.ltr);
      });
    }
  }
}
