# accessibility_service

A Flutter plugin that provides a unified interface for accessibility features across iOS and Android platforms. The plugin allows you to monitor accessibility announcement completions in real-time, detecting when announcements finish playing.

## Features

- **Announcement Completion Monitoring**: Get real-time updates when accessibility announcements complete
- **Cross-Platform Support**: Works on both iOS and Android with platform-specific implementations
- **Stream-Based API**: Use reactive streams to listen for announcement completion events
- **Easy Integration**: Simple API that integrates seamlessly with Flutter's accessibility features

## Platform Support

| Platform | Minimum Version   | Implementation                     |
|----------|-------------------|------------------------------------|
| Android  | API 26 (Oreo 8.0) | AudioManager.AudioPlaybackCallback |
| iOS      | iOS 9.0+          | UIAccessibility notifications      |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  accessibility_service: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'dart:async';
import 'package:accessibility_service/accessibility_event.dart';
import 'package:accessibility_service/accessibility_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _accessibilityService = AccessibilityService.instance;
  StreamSubscription<AccessibilityEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupListener() {
    // Subscribe to announcement completion events
    _subscription = _accessibilityService.announcementStateChanges.listen(
      (event) {
        if (event is AccessibilityAnnouncementCompleted) {
          print('Accessibility announcement completed');
        }
      },
    );
  }

  void _triggerAnnouncement() {
    // Trigger an accessibility announcement
    SemanticsService.sendAnnouncement(
      View.of(context),
      'This is a test announcement',
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _triggerAnnouncement,
      child: const Text('Test Announcement'),
    );
  }
}
```

## API Reference

### AccessibilityService

The `AccessibilityService` is implemented as a singleton to ensure consistent state management across your application.

#### Singleton Instance

Access the service using the static `instance` getter:

```dart
final service = AccessibilityService.instance;
```

#### Properties

##### `Stream<AccessibilityEvent> announcementStateChanges`

Returns a broadcast stream that emits `AccessibilityAnnouncementCompleted` events when accessibility announcements finish playing.

**Event Types:**
- `AccessibilityAnnouncementCompleted`: Emitted when an announcement completes

**Note**: This feature requires:
- **Android**: API 26 (Android 8.0 Oreo) or higher, TalkBack or another screen reader enabled
- **iOS**: VoiceOver or other accessibility features enabled

## Platform-Specific Notes

### Android

The plugin uses `AudioManager.AudioPlaybackCallback` to monitor audio playback with the `USAGE_ASSISTANCE_ACCESSIBILITY` usage type. This requires:
- Android API 26 (Oreo 8.0) or higher
- TalkBack or another screen reader to be enabled for announcement completions to be detected

### iOS

The plugin uses `UIAccessibility.announcementDidFinishNotification` to detect when accessibility announcements complete. This works with:
- VoiceOver enabled
- Any accessibility feature that uses system announcements

## Example App

The plugin includes a comprehensive example app that demonstrates:
- Real-time announcement completion detection
- Event logging with timestamps
- Completion statistics tracking
- Time interval measurement between completions
- Visual feedback for announcement events

To run the example:

```bash
cd example
flutter run
```

See the [example README](example/README.md) for more details.

## Troubleshooting

### Announcements not detected on Android
- Ensure TalkBack is enabled in Settings > Accessibility
- Verify your device is running Android 8.0 (API 26) or higher

### Announcements not detected on iOS
- Enable VoiceOver in Settings > Accessibility > VoiceOver
- Make sure your device is not in silent mode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


