import 'dart:async';

import 'package:accessibility_service/accessibility_event.dart';
import 'package:accessibility_service/accessibility_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccessibilityService', () {
    test('two parallel subscriptions receive the same events', () async {
      // Setup mock event channel
      const channelName = 'accessibility_service/announcement_state';
      final controller = StreamController<dynamic>.broadcast();
      StreamSubscription<dynamic>? mockSubscription;

      // Mock the event channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
        const EventChannel(channelName),
        MockStreamHandler.inline(
          onListen: (arguments, events) {
            mockSubscription = controller.stream.listen(
              (event) => events.success(event),
              onError: (error) => events.error(code: 'error', message: error.toString()),
              onDone: () => events.endOfStream(),
            );
          },
          onCancel: (arguments) {
            mockSubscription?.cancel();
          },
        ),
      );

      // Get the AccessibilityService instance
      final service = AccessibilityService.instance;

      // Create two parallel subscriptions
      final events1 = <AccessibilityEvent>[];
      final events2 = <AccessibilityEvent>[];

      final subscription1 = service.announcementStateChanges.listen((event) {
        events1.add(event);
      });

      final subscription2 = service.announcementStateChanges.listen((event) {
        events2.add(event);
      });

      // Emit test events (the actual event data doesn't matter,
      // all events are converted to AccessibilityAnnouncementCompleted)
      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify both subscriptions received the same number of events
      expect(events1.length, 4);
      expect(events2.length, 4);

      // Verify all events are AccessibilityAnnouncementCompleted
      expect(events1.every((e) => e is AccessibilityAnnouncementCompleted), true);
      expect(events2.every((e) => e is AccessibilityAnnouncementCompleted), true);

      // Clean up
      await subscription1.cancel();
      await subscription2.cancel();
      await controller.close();
    });

    test('one subscription cancelled, then new subscription receives events', () async {
      // Setup mock event channel
      const channelName = 'accessibility_service/announcement_state';
      final controller = StreamController<dynamic>.broadcast();
      StreamSubscription<dynamic>? mockSubscription;

      // Mock the event channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
        const EventChannel(channelName),
        MockStreamHandler.inline(
          onListen: (arguments, events) {
            mockSubscription = controller.stream.listen(
              (event) => events.success(event),
              onError: (error) => events.error(code: 'error', message: error.toString()),
              onDone: () => events.endOfStream(),
            );
          },
          onCancel: (arguments) {
            mockSubscription?.cancel();
          },
        ),
      );

      final service = AccessibilityService.instance;

      // Create first subscription
      final events1 = <AccessibilityEvent>[];
      final subscription1 = service.announcementStateChanges.listen((event) {
        events1.add(event);
      });

      // Emit events while first subscription is active
      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      // Cancel first subscription
      await subscription1.cancel();

      // Create second subscription after first is cancelled
      final events2 = <AccessibilityEvent>[];
      final subscription2 = service.announcementStateChanges.listen((event) {
        events2.add(event);
      });

      // Emit more events
      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify first subscription received only first two events
      expect(events1.length, 2);
      expect(events1.every((e) => e is AccessibilityAnnouncementCompleted), true);

      // Verify second subscription received only last two events
      expect(events2.length, 2);
      expect(events2.every((e) => e is AccessibilityAnnouncementCompleted), true);

      // Clean up
      await subscription2.cancel();
      await controller.close();
    });

    test('one of two subscriptions cancelled, other continues receiving events', () async {
      // Setup mock event channel
      const channelName = 'accessibility_service/announcement_state';
      final controller = StreamController<dynamic>.broadcast();
      StreamSubscription<dynamic>? mockSubscription;

      // Mock the event channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
        const EventChannel(channelName),
        MockStreamHandler.inline(
          onListen: (arguments, events) {
            mockSubscription = controller.stream.listen(
              (event) => events.success(event),
              onError: (error) => events.error(code: 'error', message: error.toString()),
              onDone: () => events.endOfStream(),
            );
          },
          onCancel: (arguments) {
            mockSubscription?.cancel();
          },
        ),
      );

      final service = AccessibilityService.instance;

      // Create two parallel subscriptions
      final events1 = <AccessibilityEvent>[];
      final events2 = <AccessibilityEvent>[];

      final subscription1 = service.announcementStateChanges.listen((event) {
        events1.add(event);
      });

      final subscription2 = service.announcementStateChanges.listen((event) {
        events2.add(event);
      });

      // Emit events while both subscriptions are active
      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      // Cancel first subscription
      await subscription1.cancel();

      // Emit more events (only subscription2 should receive them)
      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify first subscription received only first two events
      expect(events1.length, 2);
      expect(events1.every((e) => e is AccessibilityAnnouncementCompleted), true);

      // Verify second subscription received all four events
      expect(events2.length, 4);
      expect(events2.every((e) => e is AccessibilityAnnouncementCompleted), true);

      // Clean up
      await subscription2.cancel();
      await controller.close();
    });
  });
}
