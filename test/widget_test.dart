import 'package:flutter_test/flutter_test.dart';
import 'package:mon_retraite_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MonRetraiteApp());
    await tester.pumpAndSettle();

    // Vérifier que l'app se charge et affiche le dashboard
    expect(find.text('Mon épargne retraite'), findsOneWidget);
  });
}
