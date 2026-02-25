import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';
import 'package:pulse_frontend/ui/status_badge.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatusBadge', () {
    testWidgets('shows correct label for newTask', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.newTask)));
      expect(find.text('חדש'), findsOneWidget);
    });

    testWidgets('shows correct label for inProgress', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.inProgress)));
      expect(find.text('בביצוע'), findsOneWidget);
    });

    testWidgets('shows correct label for onHold', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.onHold)));
      expect(find.text('מוקפא'), findsOneWidget);
    });

    testWidgets('shows correct label for done', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.done)));
      expect(find.text('הסתיים'), findsOneWidget);
    });

    testWidgets('shows correct label for canceled', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.canceled)));
      expect(find.text('בוטל'), findsOneWidget);
    });

    testWidgets('canceled status shows lineThrough decoration', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.canceled)));
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('בוטל'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('non-canceled status has no lineThrough', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(status: WorkItemStatus.inProgress)));
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('בביצוע'));
      expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });
}
