import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';




void main() {

  group('Dropdown Field Testing', () {

    testWidgets('List View Test', (WidgetTester tester) async {
      await tester.widgetList(find.byKey(Key('MyIrListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      await tester.widgetList(find.byKey(Key('PendinActionListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      await tester.widgetList(find.byKey(Key('ActionTakenListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      await tester.widgetList(find.byKey(Key('IncidentHistoryListViewKey')));
      await tester.pump();
    });


  });
}

