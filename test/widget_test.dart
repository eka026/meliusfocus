
import 'package:flutter_test/flutter_test.dart';
import 'package:cs_310_project/main.dart'; // Make sure this path is correct

void main() {
  testWidgets('Deck tap opens flashcard screen and shows question',
      (WidgetTester tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());

    // Verify we are on the deck selection screen
    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);

    // Tap the "Biology" deck
    await tester.tap(find.text('Biology'));
    await tester.pumpAndSettle(); // Wait for navigation

    // Verify we are now on the flashcard screen (question shows)
    expect(find.text('What is the capital of France?'), findsOneWidget);
  });

  testWidgets('Tapping flashcard shows answer',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to flashcard screen directly
    await tester.tap(find.text('Biology'));
    await tester.pumpAndSettle();

    // Initially the question should show
    expect(find.text('What is the capital of France?'), findsOneWidget);

    // Tap to flip the card
    await tester.tap(find.text('What is the capital of France?'));
    await tester.pump();

    // Answer should now be visible
    expect(find.text('Paris'), findsOneWidget);
  });
}
