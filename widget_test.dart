import 'package:flutter_test/flutter_test.dart';
import 'package:courtscore/main.dart';

void main() {
  testWidgets('score keeper shows teams and starting scores',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CourtScoreApp());

    expect(find.text('COURTSCORE'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('AWAY'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });
}
