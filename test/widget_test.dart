// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:padel_score_app/main.dart';

// This repo's PadelApp doesn't render the default counter widget.
// Keep this test lightweight by just verifying the app builds.

void main() {
  testWidgets('App builds (smoke test)', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelApp());

    // This app doesn't expose a simple global counter in the widget tree.
    // Smoke-build is enough for CI.

    // No interactions here: we only smoke-test that the widget tree builds.
  });
}
