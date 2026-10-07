import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_vault/src/core/app_exception.dart';
import 'package:pixel_vault/src/presentation/widgets/error_view.dart';

void main() {
  testWidgets('ErrorView shows message and retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            error: const AppException('No internet connection.'),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('No internet connection.'), findsOneWidget);

    final button = tester.widget<CNButton>(find.byType(CNButton));
    button.onPressed?.call();
    expect(retried, isTrue);
  });

  testWidgets('ErrorView hides retry when not retryable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorView(
            error: MissingApiKeyException(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CNButton), findsNothing);
  });

  testWidgets('EmptyView renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyView(
            icon: Icons.favorite_border,
            title: 'No favorites yet',
            subtitle: 'Tap the heart',
          ),
        ),
      ),
    );

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(find.text('Tap the heart'), findsOneWidget);
  });
}
