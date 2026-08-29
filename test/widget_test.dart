import 'package:cattalk_ai/main.dart';
import 'package:cattalk_ai/models/cat_state.dart';
import 'package:cattalk_ai/screens/interaction_goal_screen.dart';
import 'package:cattalk_ai/screens/prediction_result_screen.dart';
import 'package:cattalk_ai/services/frame_quality_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every interaction goal maps to a unique sound', () {
    final soundIds = UserGoal.values.map((goal) => goal.soundId).toSet();

    expect(soundIds, hasLength(UserGoal.values.length));
    expect(UserGoal.calmCat.soundId, 'calm_purr_01');
    expect(UserGoal.callCat.soundId, 'food_call_01');
    expect(UserGoal.playWithCat.soundId, 'play_chirp_01');
    expect(UserGoal.buildTrust.soundId, 'soft_trill_01');
    expect(UserGoal.getAttention.soundId, 'short_meow_01');
  });

  test('frame quality favors a clear, well-lit, close cat image', () {
    final strongFrame = FrameQualityService.calculate(
      detectionConfidence: 0.91,
      brightness: 0.55,
      sharpness: 0.14,
      areaRatio: 0.30,
    );
    final weakFrame = FrameQualityService.calculate(
      detectionConfidence: 0.72,
      brightness: 0.08,
      sharpness: 0.01,
      areaRatio: 0.08,
    );

    expect(strongFrame, greaterThan(weakFrame));
    expect(strongFrame, inInclusiveRange(0, 1));
  });

  testWidgets('home presents the streamlined scan experience', (tester) async {
    await tester.pumpWidget(const CatTalkApp());

    expect(find.text('CatTalk'), findsOneWidget);
    expect(find.text('HI, MRUNALI'), findsOneWidget);
    expect(find.text('Listen with\nyour eyes.'), findsOneWidget);
    expect(find.text('Open the camera'), findsOneWidget);
    expect(find.text('Use an existing photo'), findsOneWidget);
    expect(find.textContaining('not veterinary advice'), findsOneWidget);
  });

  testWidgets('photo scan opens from the alternate action', (tester) async {
    await tester.pumpWidget(const CatTalkApp());

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -620));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use an existing photo'));
    await tester.pumpAndSettle();

    expect(find.text('Photo scan'), findsOneWidget);
    expect(find.text('Choose a clear moment.'), findsOneWidget);
    expect(find.text('Your photo will appear here'), findsOneWidget);
  });

  testWidgets('desktop home layout completes without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CatTalkApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Listen with\nyour eyes.'), findsOneWidget);
  });

  testWidgets('dark home remains polished on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CatTalkApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Open the camera'), findsOneWidget);
    expect(find.text('Use an existing photo'), findsOneWidget);
  });

  testWidgets('close live scores render as an uncertain two-state result', (
    tester,
  ) async {
    final result = CatStateResult(
      state: CatState.playfulActive,
      confidence: 0.39,
      scores: const {
        CatState.playfulActive: 0.39,
        CatState.alertCautious: 0.32,
        CatState.relaxed: 0.29,
      },
      reasons: const ['Automatic visual estimate.'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PredictionResultScreen(
          result: result,
          advisory: 'Visual estimate only.',
          sourceLabel: 'Live camera snapshot',
          secondaryActionLabel: 'Return to live camera',
        ),
      ),
    );

    expect(find.text('Playful & active or Alert & cautious'), findsOneWidget);
    expect(find.text('Mixed visual signals'), findsOneWidget);
    expect(find.textContaining('overlapping visual patterns'), findsOneWidget);
  });
}
